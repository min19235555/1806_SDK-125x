#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=arp-scan
PKG_VERSION:=1.9-40-g69b2f70
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0
PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/royhills/arp-scan.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=69b2f70588565385f3a61d9b1f100f01747cd5e1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

#PKG_FIXUP:=autoreconf

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/arp-scan
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ARP scanner
  DEPENDS:=+libpcap
  URL:=https://github.com/royhills/arp-scan
  PKG_MAINTAINER:=Sergey Urushkin <urusha.v1.0@gmail.com>
endef

define Package/arp-scan/description
    ARP scanner
endef

TARGET_CFLAGS += -fPIC  -I../src -I$(STAGING_DIR)/usr/include  -O2 -Wall

# The configure stage has to probe for pcap.h against the target staging
# headers. The custom configure below used to run without any of the
# OpenWrt configure variables, so the cross compiler was never told where
# the libpcap headers live and the probe failed. HAVE_PCAP_H stayed
# undefined and arp-scan.h was then compiled without <pcap.h>, producing
# "unknown type name pcap_t" and "dereferencing pointer to incomplete type
# 'const struct pcap_pkthdr'".
#
# Pass the cross toolchain ($(TARGET_CONFIGURE_OPTS)) plus the target
# staging include/library paths so that:
#   - configure compiles its tests with the cross compiler, and
#   - pcap.h is found in $(STAGING_DIR)/usr/include.
#
# NOTE: do not add $(CONFIGURE_ARGS) here. It carries --prefix=/usr, while
# the install rule below expects the autoconf default prefix /usr/local.
define Build/Configure
    (cd $(PKG_BUILD_DIR)/; rm -f configure config.h config.h.in Makefile.in ; autoreconf -ifv ;\
		    ./configure --with-pic --host=$(GNU_TARGET_NAME) \
			$(TARGET_CONFIGURE_OPTS) \
			CPPFLAGS="$(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)" \
			LDFLAGS="$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)";\
			    );
endef

define Build/Compile
    $(MAKE) -C $(PKG_BUILD_DIR)/ \
				$(TARGET_CONFIGURE_OPTS) \
				CFLAGS="$(TARGET_CFLAGS)" \
				CPPFLAGS="$(TARGET_CPPFLAGS)" \
				LDFLAGS="$(TARGET_LDFLAGS) -lpcap"
endef

define Package/arp-scan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(if $(wildcard $(PKG_INSTALL_DIR)/usr/local/bin/arp-scan), \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/arp-scan $(1)/usr/bin/, \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/arp-scan $(1)/usr/bin/)
endef

$(eval $(call BuildPackage,arp-scan))
