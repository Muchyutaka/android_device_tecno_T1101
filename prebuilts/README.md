# T1101 stock prebuilts

These inputs were verified against the matching stock images supplied for the
Tecno MegaPad 11 T1101 (`T1101-OP`, Android 14 system build
`UP1A.231005.007 / 260410V1133`). These identifiers describe the supplied
images, not a requirement that a firmware archive's filename use the same
version label. The OEM may leave package labels unchanged.

| File | Source | Notes |
|---|---|---|
| `kernel` | stock `boot.img` kernel payload | gzip-compressed ARM64 Linux image; Linux `5.10.237-android12-9-g9d8141349139-dirty` |
| `dtb.img` | stock `vendor_boot.img` DTB payload | MediaTek DT table wrapper containing one FDT; MT6789 / `androidboot.hardware=mt6789` |
| `dtb/mt6789.dtb` | copy of `dtb.img` | directory form consumed by `BOARD_PREBUILT_DTBIMAGE_DIR`; kept as the stock MTK table payload |
| `dtbo.img` | stock `dtbo.img` | MD5 verified against the supplied Drive image (`99f9605a49a14d3a6611492cf161d4ba`); keep paired with this kernel/DTB |
| `modules/*.ko` | stock `vendor_boot.img` vendor ramdisk | 207 modules, all with matching `vermagic` |
| `modules/modules.load` | stock normal load list | duplicate `tran_chg.ko` / `tran_battery_aging.ko` entries removed |
| `modules/modules.load.recovery` | stock recovery load list | deduplicated, order preserved |

`SHA256SUMS` covers the kernel, DTB, DTBO, module binaries, and load lists.
Run `python3 tools/validate_tree.py` from the device tree root to verify them.

The stock vendor ramdisk also contains first-stage/recovery userspace binaries.
Those are **not** copied here; the ROM build generates its own generic ramdisk,
recovery resources, and module load lists from `BoardConfig.mk` / `device.mk`.
