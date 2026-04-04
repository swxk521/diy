# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-natmap
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Richard Yu <yurichard3839@gmail.com>

LUCI_TITLE:=LuCI Support for natmap
LUCI_DEPENDS:=+natmap +luci-base

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-natmap
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=$(LUCI_DEPENDS)
  PKGARCH:=all
endef

define Package/luci-app-natmap/description
  LuCI Support for natmap - NAT port mapping tool.
endef

define Build/Compile
endef

define Package/luci-app-natmap/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/natmap.lua $(1)/usr/lib/lua/luci/controller/natmap.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/natmap.lua $(1)/usr/lib/lua/luci/model/cbi/natmap.lua

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./po/zh-cn/natmap.lmo $(1)/usr/lib/lua/luci/i18n/natmap.zh-cn.lmo 2>/dev/null || true
	$(INSTALL_DATA) ./po/en/natmap.lmo $(1)/usr/lib/lua/luci/i18n/natmap.en.lmo 2>/dev/null || true

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/luci-app-natmap $(1)/etc/uci-defaults/luci-app-natmap
endef

$(eval $(call BuildPackage,luci-app-natmap))
