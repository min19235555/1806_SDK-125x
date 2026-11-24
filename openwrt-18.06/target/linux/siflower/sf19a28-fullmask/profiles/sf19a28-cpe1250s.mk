#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/SF19A28-CPE1250S
 NAME:= Mine 5G CPE (CPE1250S)
 PACKAGES:= \
	kmod-button-hotplug \
	kmod-usb2 \
	kmod-usb-ohci \
	kmod-usb-acm \
	kmod-usb-net \
	kmod-usb-net-cdc-ether \
	kmod-usb-net-cdc-ncm \
	kmod-usb-net-cdc-mbim \
	kmod-usb-net-cdc-subset \
	kmod-usb-net-qmi-wwan \
	kmod-usb-net-rndis \
	kmod-usb-serial \
	kmod-usb-serial-option \
	kmod-usb-serial-wwan \
	kmod-usb-wdm \
	qmodem \
	luci-app-qmodem-next
endef

define Profile/SF19A28-CPE1250S/Description
 Support for the Mine 5G CPE (Siflower SF19A28, CPE1250S board)
endef

define Profile/SF19A28-CPE1250S/Config
	select BUSYBOX_DEFAULT_FEATURE_TOP_SMP_CPU
	select BUSYBOX_DEFAULT_FEATURE_TOP_DECIMALS
	select BUSYBOX_DEFAULT_FEATURE_TOP_SMP_PROCESS
	select BUSYBOX_DEFAULT_FEATURE_TOPMEM
	select BUSYBOX_DEFAULT_FEATURE_USE_TERMIOS
	select BUSYBOX_DEFAULT_CKSUM
	select TARGET_ROOTFS_SQUASHFS
endef

$(eval $(call Profile,SF19A28-CPE1250S))
