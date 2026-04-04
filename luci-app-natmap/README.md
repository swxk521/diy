# luci-app-natmap (OpenWrt 18.06 兼容版)

本插件从 OpenWrt 23.05 的 JavaScript/view 架构移植到 OpenWrt 18.06 的 Lua CBI 架构。

## 主要变更说明

| 项目 | 23.05 版 | 18.06 版 |
|------|----------|----------|
| 界面引擎 | JS `view.extend` + `form.Map` | Lua `Map` + `TypedSection` (CBI) |
| 入口注册 | `menu.d/*.json` | `luci/controller/natmap.lua` |
| 权限控制 | `rpcd/acl.d/*.json` | `uci-defaults` 脚本 |
| 翻译格式 | `.po` → 前端 JSON | `.po` → `.lmo` (po2lmo 编译) |
| 接口选择 | `widgets.NetworkSelect` | `ListValue` + uci 枚举 network 接口 |
| 状态显示 | `fs.read()` + `rpc` (JS) | `nixio.fs` + `ubus call` (Lua) |

## 功能对应关系（完全一致）

- ✅ Enable（启用开关）
- ✅ Protocol（TCP/UDP 切换）
- ✅ Restrict to address family（IPv4/IPv6/双栈）
- ✅ Interface（网络接口选择）
- ✅ Keep-alive interval（心跳间隔）
- ✅ STUN server（STUN 服务器）
- ✅ HTTP server（HTTP 服务器，仅 TCP 模式显示）
- ✅ Bind port（绑定端口）
- ✅ Forward mode（转发模式开关）
- ✅ Forward target / Forward target port（转发目标，依赖转发模式）
- ✅ Notify script（通知脚本）
- ✅ External IP / External Port（实时外部 IP 和端口状态）
- ✅ 增删实例（addremove）
- ✅ 匿名 section（anonymous）

## 目录结构

```
luci-app-natmap-1806/
├── Makefile
├── luasrc/
│   ├── controller/
│   │   └── natmap.lua          # 菜单注册 & 路由
│   └── model/cbi/
│       └── natmap.lua          # CBI 表单定义（核心逻辑）
├── po/
│   └── zh-cn/
│       └── natmap.po           # 中文翻译（需 po2lmo 编译）
└── root/
    └── etc/uci-defaults/
        └── luci-app-natmap     # 安装后初始化脚本
```

## 编译方法

将本目录放入 OpenWrt 18.06 源码的 `feeds/luci/applications/luci-app-natmap/`，然后：

```bash
# 编译翻译文件
for lang in zh-cn; do
    po2lmo po/$lang/natmap.po po/$lang/natmap.lmo
done

# 编译包
make package/luci-app-natmap/compile V=s
```

或直接 `scp` 文件到路由器（无需编译，Lua 不需要预编译）：

```bash
# 控制器
scp luasrc/controller/natmap.lua root@192.168.1.1:/usr/lib/lua/luci/controller/
# CBI 模型
scp luasrc/model/cbi/natmap.lua root@192.168.1.1:/usr/lib/lua/luci/model/cbi/
# 清除 LuCI 缓存
ssh root@192.168.1.1 "rm -rf /tmp/luci-*"
```
