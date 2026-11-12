#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/telephony.mk)

# Inherit from T1101 device
$(call inherit-product, device/tecno/T1101/device.mk)

# Project Infinity X 4.1 is on the Android 17 source line.
# Default to a vanilla unofficial build; override WITH_GAPPS=true if desired.
WITH_GAPPS ?= false
INFINITY_MAINTAINER ?= Muchyutaka
$(call inherit-product, vendor/infinity/config/common_full_tablet.mk)

PRODUCT_DEVICE := T1101
PRODUCT_NAME := infinity_T1101
PRODUCT_BRAND := TECNO
PRODUCT_MODEL := TECNO T1101
PRODUCT_MANUFACTURER := TECNO

PRODUCT_GMS_CLIENTID_BASE := android-transsion

# Matching stock system build used by the generated tree / Drive boot images.
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="T1101-OP-user 14 UP1A.231005.007 260410V1133 release-keys" \
    BuildFingerprint=TECNO/T1101-OP/TECNO-T1101:14/UP1A.231005.007/260410V1133:user/release-keys

TARGET_SCREEN_WIDTH := 1200
TARGET_SCREEN_HEIGHT := 1920
