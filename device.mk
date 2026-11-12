#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# APEX / storage
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Framework compatibility for the Android 12-era MediaTek vendor blobs.
$(call inherit-product, hardware/lineage/compat/frameworks/compat.mk)
$(call inherit-product, hardware/mediatek/frameworks/mediatek-frameworks.mk)

# Virtual A/B: this device launched with snapuserd in vendor_boot, not init_boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier \
    checkpoint_gc \
    otapreopt_script

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=$(BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE) \
    POSTINSTALL_OPTIONAL_system=true

AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_vendor=true \
    POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
    FILESYSTEM_TYPE_vendor=$(BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE) \
    POSTINSTALL_OPTIONAL_vendor=true

# Boot control / fastbootd / health / MediaTek preloader path helper.
# Use source-built services instead of the stale stock boot/health blobs;
# the corresponding proprietary entries are deliberately not extracted.
PRODUCT_PACKAGES += \
    com.android.hardware.boot:64 \
    android.hardware.boot-service.default_recovery:64 \
    android.hardware.fastboot-service.example_recovery \
    fastbootd:64 \
    android.hardware.health-service.mediatek \
    android.hardware.health-service.mediatek-recovery \
    charger_res_images_vendor \
    create_pl_dev \
    create_pl_dev.recovery

# API levels. The vendor partition launched with Android 12 (VNDK 31), even
# though the matching stock system image is Android 14. Keep the GRF shipping
# level aligned with the vendor, not the newer system image.
PRODUCT_SHIPPING_API_LEVEL := 31

# Kernel / userspace
PRODUCT_ENABLE_UFFD_GC := true
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

# Android 17 no longer provides the legacy OMX service; this vendor uses Codec2.
TARGET_SUPPORTS_OMX_SERVICE := false
TARGET_REQUIRES_HIDL_CAS_HAL := false

# Overlays
PRODUCT_ENFORCE_RRO_TARGETS := *

# Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Product characteristics
PRODUCT_CHARACTERISTICS := tablet
PRODUCT_AAPT_PREF_CONFIG := xlarge

# Rootdir: normal-boot init only. Factory/meta/multi_init dumps are kept in the
# repository for reference but are not installed into the ROM.
PRODUCT_PACKAGES += \
    init.insmod.sh \
    init.insmod.mt6789.cfg \
    init.tran_mcf.sh \
    fstab.mt6789 \
    fstab.mt6789.vendor_ramdisk \
    fstab.mt8781 \
    fstab.mt8781.vendor_ramdisk \
    init.aee.rc \
    init.cgroup.rc \
    init.connectivity.common.rc \
    init.connectivity.rc \
    init.modem.rc \
    init.mt6789.rc \
    init.mt6789.usb.rc \
    init.mtkgki.rc \
    init.project.rc \
    init.sensor_2_0.rc \
    init_connectivity.rc

# Permissions / tablet features. Keep this conservative: only features already
# supported by the stock T1101 configuration are declared here.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.distinct.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml

# Wi-Fi: source-built AIDL HAL + wrapper around the stock MediaTek legacy HAL.
$(call soong_config_set_bool,mediatek_wifi_hal,use_pre_u_qpr2_struct,true)
PRODUCT_PACKAGES += \
    android.hardware.wifi-service \
    hostapd \
    libwifi-hal-wrapper:64 \
    wlan_assistant \
    wpa_supplicant \
    libkeystore-wifi-hidl:64 \
    libkeystore-engine-wifi-hidl:64

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Inherit the proprietary files
$(call inherit-product, vendor/tecno/T1101/T1101-vendor.mk)
