# TECNO MegaPad 11 (T1101) — Project Infinity X 4.1 device tree

Unofficial **bringup** device tree for the Tecno MegaPad 11 (`T1101`, MediaTek
Helio G99 / MT6789). It targets **Project Infinity X 4.1** (Android 17 /
Lineage 24.0 base) using the supplied stock boot prebuilts and an
Android 12-era vendor. Firmware package labels may differ from the internal
build identifiers; compatibility must be checked from the image contents.

> Status: ported from the aospdtgen/Lineage skeleton and statically validated.
> It has **not** been compiled as a full ROM or boot-tested in this workspace.
> You still need to extract the matching proprietary vendor tree and complete
> SELinux/hardware bringup. Do not treat this as a stable daily-driver tree yet.

## Device

| Item | Value |
|---|---|
| Codename / model | `T1101` / TECNO MegaPad 11 |
| SoC | MediaTek Helio G99, platform `mt6789` (stock also uses `mt8781` aliases) |
| CPU | 2× Cortex-A76 + 6× Cortex-A55, arm64 + arm |
| Display | 1200×1920, 280 dpi, tablet |
| Reference stock fingerprint | `TECNO/T1101-OP/TECNO-T1101:14/UP1A.231005.007/260410V1133:user/release-keys` |
| Stock vendor | Android 12 era, VNDK 31, first API 31, security patch `2025-04-05` |
| Kernel | prebuilt `5.10.237-android12-9-g9d8141349139-dirty` |
| Boot | header v4, GKI-style `boot` + `vendor_boot`, separate `dtbo` |
| Updates | Virtual A/B, userspace snapshots, dynamic partitions (`main` group) |
| SIM | DSDS (the old vendor.prop had stale `ss` overrides; corrected) |

## What was fixed compared with the generated tree

- Added `infinity_T1101` product/lunch targets and removed the stale
  `lineage_T1101` product.
- Inherited Infinity X's **tablet** configuration plus AOSP telephony for the
  LTE tablet, instead of the phone configuration.
- Set `PRODUCT_SHIPPING_API_LEVEL := 31` to match the vendor/GRF level, not the
  newer Android 14 system image.
- Corrected recovery layout: recovery/fastbootd resources live in `vendor_boot`,
  not `BOARD_USES_RECOVERY_AS_BOOT`.
- Added the missing `vendor_boot`, `dtbo`, and `vbmeta*` A/B partitions.
- Used the stock boot parameters, prebuilt kernel, DTB, DTBO, and **207 kernel
  modules** extracted from the matching stock `vendor_boot.img`.
- Added normal/recovery module load lists and a second-stage `init.insmod`
  configuration that works with modules in `vendor` or `vendor_dlkm`.
- Installed fstab for both `mt6789` and `mt8781`; the stock DTB reports
  `androidboot.hardware=mt6789`, so the old `fstab.mt8781`-only setup was unsafe.
- Fixed the fstab double-comma typo, removed the duplicate `/system` ext4 line,
  removed Transsion `tr_*` logical mounts that are not built by this ROM, and
  added zram.
- Replaced stale stock boot/health HAL blobs with source-built services:
  AOSP AIDL boot control + recovery, MediaTek AIDL health + recovery.
- Switched fastbootd to the AIDL example service and added `create_pl_dev`.
- Replaced the stock HIDL Wi-Fi userspace with the source-built AIDL Wi-Fi HAL,
  MediaTek `libwifi-hal-wrapper`, `wpa_supplicant`, `hostapd`, and
  `wlan_assistant`; the stock legacy HAL is kept as `libwifi-hal-mtk.so`.
- Added MediaTek/Lineage framework compatibility for the old vendor blobs.
- Pruned conflicting stock product properties and hundreds of log-tag overrides.
- Removed legacy OMX/RenderScript/CAS entries for Android 17.
- Aligned the device manifest composer entry to stock `@2.3` and added VINTF
  device/framework compatibility matrices.
- Added a local manifest that pins `vendor/infinity` to the actual **4.1**
  version commit (`9a651bc8c52730a4c57a4984fb6a846067c8b2f4`). Upstream branch
  `17` has already moved to 4.2.
- Added `tools/validate_tree.py` and `prebuilts/SHA256SUMS`.

## Known risks

- **Android 17 system + VNDK 31 vendor is a bringup risk.** The tree keeps the
  stock vendor blobs rather than pretending to have a newer vendor. Some HALs
  (IMS/VoLTE, DRM, camera aux, Transsion services) may need extra patches.
- There is **no kernel source** here; the kernel/DTB/DTBO/modules are stock
  prebuilts. Do not enable official-build flags that force a kernel build.
- AVB currently uses public AOSP test keys and `--flags 3` for unlocked bringup.
  **Do not lock the bootloader** with this configuration.
- SELinux is not permissive, but the vendor policy still needs a full audit
  against Android 17. Collect denials and add targeted rules.
- The proprietary list is not hash-pinned yet. Pin it after verifying the
  supplied firmware dump.

## Source setup

Use a Linux x86_64 host with the usual AOSP/Lineage build dependencies and
enough disk space for a full Android 17 checkout.

```bash
mkdir ~/infinityx && cd ~/infinityx
repo init --no-repo-verify --git-lfs \
  -u https://github.com/ProjectInfinity-X/manifest -b 17 \
  -g default,-mips,-darwin,-notdefault

mkdir -p .repo/local_manifests

# If this device tree is already checked out somewhere, copy its local manifest:
cp /path/to/android_device_tecno_T1101/local_manifests/infinity-4.1.xml \
  .repo/local_manifests/

# Or clone the device tree first, then copy the file:
git clone -b arena/ca033d92-android-device-tecno-t1101 \
  https://github.com/Muchyutaka/android_device_tecno_T1101 \
  device/tecno/T1101
cp device/tecno/T1101/local_manifests/infinity-4.1.xml .repo/local_manifests/

repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc)
```

The local manifest currently points the device tree at branch
`arena/ca033d92-android-device-tecno-t1101`. After merging this work into
`main`, change that revision to `main`.

## Extract proprietary files

The device tree does **not** contain the full vendor blobs. Extract them from
the supplied T1101 firmware, or from the device itself. The OEM may leave older
or different build names on firmware packages without updating their labels.
A package-name/fingerprint difference alone does **not** mean the firmware is
wrong; check the actual partition contents and kernel/vendor compatibility.

```bash
cd ~/infinityx/device/tecno/T1101

# From an unpacked firmware root containing vendor/, system_ext/, product/, etc.
./extract-files.py /path/to/unpacked/firmware

# Or from a connected device running the intended stock firmware (ADB is default):
./extract-files.py

# If you only changed proprietary-files.txt and already have the vendor tree:
./setup-makefiles.py
```

This generates `vendor/tecno/T1101` in the ROM root. Do not commit the generated
vendor tree unless you intentionally maintain a separate proprietary repository.

The Drive folder used for reference contained `boot.img`, `vendor_boot.img`, and
`dtbo.img` dated 2026-04-10. The kernel/DTB/module hashes match the boot images,
and the DTBO MD5 matches the supplied Drive image. The larger firmware archives
can have different or older package labels because the OEM did not update the
version names. Do not reject them on that basis alone, or assume every archive
is interchangeable: verify the extracted contents and keep compatible boot and
vendor components paired. Full vendor extraction and hash pinning are still
pending.

## Build

```bash
cd ~/infinityx
source build/envsetup.sh
lunch infinity_T1101-userdebug
m bacon
```

Defaults: unofficial, vanilla (`WITH_GAPPS=false`). To include GApps:

```bash
WITH_GAPPS=true m bacon
```

## Validate the tree

From the device tree root:

```bash
python3 tools/validate_tree.py
```

This checks product registration, boot/recovery flags, fstab aliases, module
load lists, prebuilt hashes, manifest cleanup, Wi-Fi/VINTF wiring, and the 4.1
local-manifest pin. It is not a substitute for `m bacon`, VINTF checks, or
on-device testing.

## Bringup checklist

1. Extract the matching vendor tree and run a full build.
2. Resolve any missing-module/SELinux/VINTF errors; do not disable SELinux.
3. Back up the device and keep a known-good recovery route.
4. Test `boot.img`, `vendor_boot.img`, and `dtbo.img` on an unlocked bootloader.
5. Verify first-stage mount, metadata encryption, touch/display, Wi-Fi, audio,
   cameras, sensors, charging, sleep, RIL/DSDS, and OTA/snapshot merge.
6. Replace test AVB keys and remove `--flags 3` before any locked/production use.

## References

- Project Infinity X manifest, branch `17`:
  <https://github.com/ProjectInfinity-X/manifest/tree/17>
- Infinity X vendor 4.1 pin:
  <https://github.com/ProjectInfinity-X/vendor_infinity/commit/9a651bc8c52730a4c57a4984fb6a846067c8b2f4>
- Matching T1101 recovery tree:
  <https://github.com/Muchyutaka/Recovery-Tree-T1101-Tecno-Megapad-11>
- Transsion MT6789 common-tree reference (Android 17):
  <https://github.com/MillenniumOSS/android_device_tecno_mt6789-common/tree/seventeen>
- MT6789 Android 17 porting reference:
  <https://github.com/iasnezhkov/android_device_ikko_mindone/tree/lineage-24.0>

## License

Apache-2.0 where file headers indicate. Stock kernel/modules/DTB/DTBO and
extracted proprietary blobs remain the property of their respective owners and
are only for use with this device.
