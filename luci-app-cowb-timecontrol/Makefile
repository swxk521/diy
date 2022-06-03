# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=luci-app-cowb-timecontrol
LUCI_DEPENDS:=+iptables-mod-filter +kmod-ipt-filter +iputils-arping +bash 
LUCI_PKGARCH:=all
PKG_VERSION:=v22.1.10-1414
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


