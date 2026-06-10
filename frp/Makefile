include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.69.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=79a62c1071ddb947e95146ad7b1cb8b25f182fed548a4a8a68d5fca06b37502c

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=$(if $(CONFIG_PACKAGE_frpc),$(GO_PKG)/cmd/frpc) \
	$(if $(CONFIG_PACKAGE_frps),$(GO_PKG)/cmd/frps)
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=github.com/fatedier/frp/pkg/util/version.version=$(PKG_VERSION)
GO_PKG_TAGS:=noweb

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define frp/templates
  define Package/$(1)
    TITLE:=A fast reverse proxy ($(1))
    URL:=https://github.com/fatedier/frp
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    DEPENDS:=$$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
  frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall
  to the internet. It supports TCP, UDP, HTTP and HTTPS protocols.

  This package contains the $(1) executable only.
  endef

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef
endef

$(eval $(call frp/templates,frpc))
$(eval $(call GoBinPackage,frpc))
$(eval $(call BuildPackage,frpc))

$(eval $(call frp/templates,frps))
$(eval $(call GoBinPackage,frps))
$(eval $(call BuildPackage,frps))
