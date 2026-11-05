#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from T1101 device
$(call inherit-product, device/tecno/T1101/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_DEVICE := T1101
PRODUCT_NAME := lineage_T1101
PRODUCT_BRAND := TECNO
PRODUCT_MODEL := TECNO T1101
PRODUCT_MANUFACTURER := tecno

PRODUCT_GMS_CLIENTID_BASE := android-transsion

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="T1101-OP-user 14 UP1A.231005.007 260410V1133 release-keys" \
    BuildFingerprint=TECNO/T1101-OP/TECNO-T1101:14/UP1A.231005.007/260410V1133:user/release-keys
