module("luci.controller.speedlimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/speedlimit") then return end
	entry({"admin", "services", "speedlimit"}, cbi("speedlimit"), _("网速限制"), 120).dependent = true
 end
