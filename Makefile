#
# Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
# Modified By Xingwang Liao <kuoruan@gmail.com> 2017-03-24
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-shadowsocks
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>, Xingwang Liao <kuoruan@gmail.com>

LUCI_TITLE:=LuCI support for Shadowsocks and ShadowsocksR
LUCI_DEPENDS:=+jshn +iptables +ipset +ip +iptables-mod-tproxy
LUCI_PKGARCH:=all

include ../../luci.mk

define Package/$(PKG_NAME)/config
# shown in make menuconfig <Help>
help
	$(LUCI_TITLE)
	.
	Version: $(PKG_VERSION)-$(PKG_RELEASE)
	$(PKG_MAINTAINER)
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/40_luci-shadowsocks ) && rm -f /etc/uci-defaults/40_luci-shadowsocks
	chmod 755 /etc/init.d/shadowsocks /usr/bin/ss-rules >/dev/null 2>&1
	/etc/init.d/shadowsocks enable >/dev/null 2>&1
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
