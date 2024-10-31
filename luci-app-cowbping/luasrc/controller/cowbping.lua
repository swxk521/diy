module("luci.controller.cowbping", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cowbping") then return end
	entry({"admin", "services", "cowbping"}, alias("admin", "services", "cowbping","cowbping"), _("网络检测"), 120).dependent = true
	entry({"admin", "services", "cowbping", "cowbping"}, cbi("cowbping/cowbping"),_("设置"), 10).leaf = true
	entry({"admin", "services", "cowbping", "cowblog"}, form("cowbping/cowblog"),_("日志"), 20).leaf = true
end
