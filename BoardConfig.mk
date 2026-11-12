#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# TECNO MegaPad 11 (T1101) board configuration.
# Boot parameters and kernel modules are taken from the matching stock
# boot.img / vendor_boot.img, not from a generic MT6789 template.

DEVICE_PATH := device/tecno/T1101

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    odm_dlkm \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := TECNO-T1101
TARGET_NO_BOOTLOADER := true
TARGET_OTA_ASSERT_DEVICE := T1101,TECNO-T1101

# Display
TARGET_SCREEN_DENSITY := 280
TARGET_USES_VULKAN := true

# Kernel: stock prebuilt, header version 4 / GKI-style vendor_boot.
BOARD_BOOT_HEADER_VERSION := 4
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_KERNEL_TAGS_OFFSET := 0x07c88000
BOARD_DTB_OFFSET := 0x07c88000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_SEPARATED_DTBO := true

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/kernel
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilts/dtb
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img

# Kernel modules extracted from the matching stock vendor_boot.img.
# Keep the stock load order; the normal list has two harmless duplicates
# removed, and the recovery list is the stock recovery subset.
T1101_MODULE_PATH := $(DEVICE_PATH)/prebuilts/modules
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(T1101_MODULE_PATH)/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(T1101_MODULE_PATH)/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(T1101_MODULE_PATH)/modules.load.recovery))

# Also stage the same vendor modules in /vendor/lib/modules for the stock
# init.insmod.sh / init.mtkgki.rc second-stage loader.
BOARD_VENDOR_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES)
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)

BOARD_DO_NOT_STRIP_VENDOR_RAMDISK_MODULES := true
BOARD_DO_NOT_STRIP_RECOVERY_MODULES := true
BOARD_DO_NOT_STRIP_VENDOR_MODULES := true

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_USES_METADATA_PARTITION := true
BOARD_USES_ODM_DLKMIMAGE := true
BOARD_USES_VENDOR_DLKMIMAGE := true

BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_PARTITION_LIST := \
    odm_dlkm \
    product \
    system \
    system_ext \
    vendor \
    vendor_dlkm
BOARD_MAIN_SIZE := 9122611200

BOARD_EROFS_PCLUSTER_SIZE := 262144
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

# Platform
TARGET_BOARD_PLATFORM := mt6789

# The extracted vendor.prop still contains non-vendor namespaces (radio, dalvik,
# Wi-Fi, etc.). Allow them during bringup instead of rewriting every stock prop.
BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true
BUILD_BROKEN_DUP_RULES := true

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/product.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/system_ext.prop
TARGET_ODM_PROP += $(DEVICE_PATH)/odm.prop
TARGET_ODM_DLKM_PROP += $(DEVICE_PATH)/odm_dlkm.prop
TARGET_VENDOR_DLKM_PROP += $(DEVICE_PATH)/vendor_dlkm.prop

# Recovery / fastbootd live in vendor_boot on this device.
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6789
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# SELinux. The MediaTek vendor policy baseline is supplied by the local
# manifest; device-specific additions live under sepolicy/vendor.
include device/mediatek/sepolicy_vndr/SEPolicy.mk
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Security patch level of the matching stock vendor build.
VENDOR_SECURITY_PATCH := 2025-04-05

# Verified Boot. These are public AOSP test keys for unlocked bringup only.
# --flags 3 disables verification; do not ship this configuration locked.
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := SHA256_RSA4096
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3

BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ROLLBACK_INDEX := 1
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VENDOR_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VENDOR_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := 1
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_SYSTEM := product system system_ext
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := 1
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := 1
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 4

BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256

# VINTF. Stock vendor manifest fragments are extracted into vendor/etc/vintf;
# this file only carries the legacy device-manifest entries not provided by
# the source-built boot/health/fastboot HALs.
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE += $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += $(DEVICE_PATH)/configs/vintf/device_framework_compatibility_matrix.xml

# Wi-Fi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_FW_PATH_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_STATE_ON := "1"
WIFI_DRIVER_STATE_OFF := "0"
WIFI_HAL_INTERFACE_COMBINATIONS := {{{STA}, 2}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{AP_BRIDGED}, 1},}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{AP}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{P2P}, 1}}
WIFI_HAL_INTERFACE_COMBINATIONS += ,{{{STA}, 1}, {{NAN}, 1}}
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

# Inherit the proprietary files
include vendor/tecno/T1101/BoardConfigVendor.mk
