# T1101 vendor SELinux additions

This directory is intentionally small. The baseline MediaTek vendor policy is
included from `device/mediatek/sepolicy_vndr/SEPolicy.mk` in `BoardConfig.mk`.

Do **not** make the tree permissive to hide denials. During bringup, collect
`adb shell dmesg | grep avc` and `logcat -b all | grep avc`, then add targeted
allow rules here or fix the offending label/service.

The stock vendor image still needs a full policy audit against Android 17.
