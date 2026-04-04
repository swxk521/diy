# luci-app-natmap (OpenWrt 18.06 兼容版)

本插件由 23.05 版本移植而来，适配 OpenWrt 18.06 的旧版 LuCI（Lua CBI 框架）。

## 目录结构

```
luci-app-natmap-18.06/
├── Makefile
├── luasrc/
│   ├── controller/
│   │   └── natmap.lua          # 路由控制器
│   └── model/cbi/
│       └── natmap.lua          # CBI 配置界面（替代原 JS view）
├── root/
│   └── etc/config/
│       └── natmap              # 默认 UCI 配置
└── po/
    └── zh_Hans/
        └── natmap.po           # 简体中文翻译
```

## 与 23.05 版的主要差异

| 项目 | 23.05 | 18.06（本版） |
|------|-------|--------------|
| 界面框架 | JS view（ucode） | Lua CBI |
| 菜单注册 | `menu.d/*.json` | `controller/natmap.lua` |
| ACL | `rpcd/acl.d/*.json` | 集成在 controller |
| 国际化 | JS `_()` + `.po` | Lua `translate()` + `.po` → `.lmo` |
| 运行状态读取 | `rpc` + `fs.read` (异步 Promise) | 同步 `nixio.fs` + `luci.util.ubus` |
| Forward 模式 | 虚拟 Flag（不写 UCI） | 真实 UCI option `forward_mode` |

## 编译说明

将本目录放入 OpenWrt SDK 的 `feeds/luci/applications/luci-app-natmap/` 下，然后：

```bash
make package/luci-app-natmap/compile V=s
```

**依赖：** `natmap`, `luci-base`，以及编译时需要 `po2lmo` 工具（luci-base 提供）。

## 注意事项

1. **Forward mode**：原版 23.05 用 `forward_target` 是否有值来判断是否开启转发，
   本版改为显式 `forward_mode` UCI 选项，需确认 natmap 的 init 脚本支持此字段，
   或在 init 脚本中改为检查 `forward_target` 是否为空。

2. **运行状态**：外部 IP/端口通过读取 `/var/run/natmap/<pid>.json` 获取，
   依赖 natmap 程序在运行时写入该文件，行为与 23.05 版一致。

3. **接口列表**：18.06 的 CBI 没有 `widgets.NetworkSelect`，改用 `sys.net.devices()`
   枚举系统网络接口。
