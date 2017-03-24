#
# Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
# Modified By Xingwang Liao <kuoruan@gmail.com> 2017-03-24
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks
PKG_VERSION:=1.6.3
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>, Xingwang Liao <kuoruan@gmail.com>

LUCI_TITLE:=LuCI support for Shadowsocks{R}
LUCI_DEPENDS:=+iptables +ipset +ip +iptables-mod-tproxy
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/config
# shown in make menuconfig <Help>
help
	$(LUCI_TITLE)
	.
	Version: $(PKG_VERSION)-$(PKG_RELEASE)
	$(PKG_MAINTAINER)
endef

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
