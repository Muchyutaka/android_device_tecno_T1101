#!/usr/bin/env python3
"""Static sanity checks for the T1101 Infinity X device tree.

This does not replace a full ROM build or on-device bringup. It checks the
porting mistakes that are easy to introduce in an aospdtgen-generated tree.
"""

from __future__ import annotations

import hashlib
import re
import struct
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []


def check(ok: bool, msg: str) -> None:
    print(("PASS" if ok else "FAIL") + ": " + msg)
    if not ok:
        FAILURES.append(msg)


def read(rel: str) -> str:
    return (ROOT / rel).read_text()


def mtk_dtb_payload(blob: bytes) -> bytes:
    """Return the first FDT inside a MediaTek dtb/dtbo table wrapper."""
    if blob[:4] == bytes.fromhex("d00dfeed"):
        return blob
    if blob[:4] != bytes.fromhex("d7b7ab1e"):
        raise ValueError("not an FDT or MTK DT table")
    magic, total, hsize, desize, count, deoffset, eoffset, eoffset2 = struct.unpack_from(">8I", blob)
    if magic != 0xD7B7AB1E or count < 1:
        raise ValueError("bad MTK DT table")
    size, off, idv, rev, custom = struct.unpack_from(">5I", blob, deoffset)
    payload = blob[off:off + size]
    if payload[:4] != bytes.fromhex("d00dfeed"):
        raise ValueError("MTK DT entry is not an FDT")
    return payload


def main() -> int:
    required = [
        "Android.bp", "Android.mk", "AndroidProducts.mk", "BoardConfig.mk",
        "device.mk", "infinity_T1101.mk", "manifest.xml",
        "configs/vintf/compatibility_matrix.xml",
        "configs/vintf/device_framework_compatibility_matrix.xml",
        "proprietary-files.txt", "extract-files.py", "setup-makefiles.py",
        "rootdir/etc/fstab.mt6789", "rootdir/etc/fstab.mt8781",
        "rootdir/etc/init.insmod.mt6789.cfg",
        "prebuilts/kernel", "prebuilts/dtb.img", "prebuilts/dtb/mt6789.dtb",
        "prebuilts/dtbo.img", "prebuilts/modules/modules.load",
        "prebuilts/modules/modules.load.recovery", "prebuilts/SHA256SUMS",
        "local_manifests/infinity-4.1.xml", ".gitignore",
    ]
    for rel in required:
        check((ROOT / rel).exists(), f"exists: {rel}")

    products = read("AndroidProducts.mk")
    check("infinity_T1101.mk" in products, "AndroidProducts registers infinity_T1101")
    check("lineage_T1101" not in products, "stale lineage lunch target removed")
    check(not (ROOT / "lineage_T1101.mk").exists(), "stale lineage product file removed")

    product = read("infinity_T1101.mk")
    check("vendor/infinity/config/common_full_tablet.mk" in product, "inherits Infinity tablet product")
    check("$(SRC_TARGET_DIR)/product/telephony.mk" in product, "inherits AOSP telephony for LTE tablet")
    check("PRODUCT_NAME := infinity_T1101" in product, "product name is infinity_T1101")
    check("WITH_GAPPS ?= false" in product, "defaults to vanilla build")

    board = read("BoardConfig.mk")
    for flag in [
        "BOARD_USES_GENERIC_KERNEL_IMAGE := true",
        "BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true",
        "BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true",
        "TARGET_NO_RECOVERY := true",
        "BOARD_BOOT_HEADER_VERSION := 4",
        "BOARD_RAMDISK_USE_LZ4 := true",
        "BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilts/dtb",
        "TARGET_BOARD_PLATFORM := mt6789",
        "BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true",
        "BOARD_WPA_SUPPLICANT_DRIVER := NL80211",
        "BOARD_HOSTAPD_DRIVER := NL80211",
        "DEVICE_MATRIX_FILE += $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml",
        "DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += $(DEVICE_PATH)/configs/vintf/device_framework_compatibility_matrix.xml",
    ]:
        check(flag in board, f"BoardConfig has {flag}")
    check("BOARD_USES_RECOVERY_AS_BOOT := true" not in board, "recovery-as-boot disabled")
    check("TARGET_KERNEL_SOURCE := kernel/tecno/T1101" not in board, "no missing kernel source path")
    check("TARGET_KERNEL_CONFIG := T1101_defconfig" not in board, "no missing kernel defconfig")

    device = read("device.mk")
    check("virtual_ab_ota/launch_with_vendor_ramdisk.mk" in device, "Virtual A/B uses vendor_ramdisk launch path")
    check("fstab.mt6789.vendor_ramdisk" in device, "fstab.mt6789 staged in vendor ramdisk")
    check("fstab.mt8781.vendor_ramdisk" in device, "fstab.mt8781 alias staged in vendor ramdisk")
    check("android.hardware.boot-service.default_recovery" in device, "source-built recovery boot control")
    check("android.hardware.health-service.mediatek" in device, "source-built MediaTek health")
    check("android.hardware.health-service.mediatek-recovery" in device, "source-built MediaTek recovery health")
    check("android.hardware.fastboot-service.example_recovery" in device, "AIDL fastbootd service")
    check("create_pl_dev" in device, "MediaTek preloader path helper")
    check("android.hardware.wifi-service" in device, "source-built AIDL Wi-Fi HAL")
    check("libwifi-hal-wrapper" in device, "MediaTek Wi-Fi HAL wrapper")
    check("PRODUCT_SHIPPING_API_LEVEL := 31" in device, "GRF shipping API aligned with VNDK 31 vendor")
    check("android.hardware.boot@1.2-impl" not in device, "stale HIDL boot packages removed")
    check("android.hardware.health@2.1-impl" not in device, "stale HIDL health packages removed")

    fstab = read("rootdir/etc/fstab.mt6789")
    check(fstab == read("rootdir/etc/fstab.mt8781"), "mt6789/mt8781 fstab aliases match")
    check(",,inlinecrypt" not in fstab, "fstab double-comma typo fixed")
    check("/dev/block/zram0" in fstab, "zram swap entry present")
    check(not re.search(r"^tr_", fstab, re.M), "stock Transsion tr_* logical mounts removed")
    check("fileencryption=aes-256-xts:aes-256-cts:v2" in fstab, "metadata encryption preserved")
    system_lines = [l for l in fstab.splitlines() if re.match(r"^system\s+/system\s+", l)]
    check(len(system_lines) == 1 and " erofs " in system_lines[0], "single erofs /system fstab entry")

    modules = {p.name for p in (ROOT / "prebuilts/modules").glob("*.ko")}
    check(len(modules) == 207, f"207 stock kernel modules present (found {len(modules)})")
    for name in ["modules.load", "modules.load.recovery"]:
        lines = [x.strip() for x in read("prebuilts/modules/" + name).splitlines() if x.strip()]
        check(len(lines) == len(set(lines)), f"{name} has no duplicates")
        missing = sorted(set(lines) - modules)
        check(not missing, f"{name} references only present modules {missing}")
    normal = set(read("prebuilts/modules/modules.load").split())
    recovery = set(read("prebuilts/modules/modules.load.recovery").split())
    check(normal | recovery <= modules, "load lists are subsets of staged modules")

    kernel = (ROOT / "prebuilts/kernel").read_bytes()
    check(kernel[:2] == b"\x1f\x8b", "prebuilt kernel is gzip-compressed")
    dtb = (ROOT / "prebuilts/dtb.img").read_bytes()
    try:
        fdt = mtk_dtb_payload(dtb)
        check(True, f"DTB payload is a valid FDT ({len(fdt)} bytes)")
    except ValueError as e:
        check(False, f"DTB payload is a valid FDT: {e}")
    check((ROOT / "prebuilts/dtb/mt6789.dtb").read_bytes() == dtb, "DTB directory copy matches dtb.img")
    dtbo = (ROOT / "prebuilts/dtbo.img").read_bytes()
    check(dtbo[:4] == bytes.fromhex("d7b7ab1e"), "DTBO has dt_table_header magic")
    try:
        mtk_dtb_payload(dtbo)
        check(True, "DTBO entry contains a valid FDT")
    except ValueError as e:
        check(False, f"DTBO entry contains a valid FDT: {e}")

    sums = ROOT / "prebuilts/SHA256SUMS"
    bad = []
    for line in sums.read_text().splitlines():
        digest, rel = line.split(maxsplit=1)
        path = ROOT / "prebuilts" / rel
        if not path.exists() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            bad.append(rel)
    check(not bad, f"SHA256SUMS verify {bad}")

    manifest = ET.parse(ROOT / "manifest.xml").getroot()
    names = {h.findtext("name") for h in manifest.findall("hal")}
    check("android.hardware.boot" not in names, "boot HAL not duplicated in device manifest")
    check("android.hardware.health" not in names, "health HAL not duplicated in device manifest")
    check("android.hardware.media.omx" not in names, "legacy OMX HAL removed")
    check("android.hardware.renderscript" not in names, "legacy RenderScript HAL removed")
    check(manifest.get("target-level") == "6", "stock FCM target level preserved")
    composer = [h for h in manifest.findall("hal") if h.findtext("name") == "android.hardware.graphics.composer"]
    check(len(composer) == 1 and composer[0].findtext("fqname") == "@2.3::IComposer/default",
          "composer manifest aligned to stock @2.3")

    blobs = {x.strip() for x in read("proprietary-files.txt").splitlines() if x.strip() and not x.startswith("#")}
    for forbidden in [
        "vendor/bin/hw/android.hardware.boot@1.2-service",
        "vendor/bin/hw/android.hardware.health@2.1-service",
        "vendor/bin/hw/android.hardware.wifi@1.0-service-lazy",
        "vendor/bin/hw/wpa_supplicant",
        "vendor/bin/hw/hostapd",
        "vendor/bin/hw/android.hardware.cas@1.2-service-lazy",
        "vendor/bin/hw/android.hardware.media.omx@1.0-service",
        "vendor/etc/fstab.mt6789",
        "vendor/etc/fstab.mt8781",
        "vendor/etc/init.insmod.mt6789.cfg",
    ]:
        check(forbidden not in blobs, f"proprietary list does not duplicate {forbidden}")
    check("vendor/lib64/libwifi-hal.so:vendor/lib64/libwifi-hal-mtk.so" in blobs,
          "stock Wi-Fi HAL renamed for the source-built wrapper")

    bp = read("rootdir/Android.bp")
    check(not re.search(r"^\s*#", bp, re.M), "rootdir Android.bp uses Soong comments")
    check("sub_dir:" not in bp, "rootdir Android.bp uses relative_install_path")
    check('name: "fstab.mt6789"' in bp and "vendor_ramdisk_available: true" in bp,
          "fstab Soong module has vendor_ramdisk variant")

    lm = ET.parse(ROOT / "local_manifests/infinity-4.1.xml").getroot()
    pinned = [p for p in lm.findall("project") if p.get("path") == "vendor/infinity"]
    check(len(pinned) == 1 and pinned[0].get("revision") == "9a651bc8c52730a4c57a4984fb6a846067c8b2f4",
          "local manifest pins vendor/infinity to Infinity X 4.1")
    for p in ["configs/vintf/compatibility_matrix.xml", "configs/vintf/device_framework_compatibility_matrix.xml"]:
        ET.parse(ROOT / p)
        check(True, f"XML parses: {p}")

    check((ROOT / "extract-files.py").stat().st_mode & 0o111 != 0, "extract-files.py is executable")
    check((ROOT / "setup-makefiles.py").stat().st_mode & 0o111 != 0, "setup-makefiles.py is executable")

    print()
    if FAILURES:
        print(f"{len(FAILURES)} check(s) failed")
        return 1
    print("All static checks passed. A full ROM build and on-device bringup are still required.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
