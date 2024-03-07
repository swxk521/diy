module("luci.controller.wrtbwmon", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/wrtbwmon") then
		return
	end
	entry({"admin","status","online"},alias("admin","status","online","onlinuser"),_("Online User"), 90)
	entry({"admin","status","online","onlinuser"},template("onlinuser"),_("User online")).leaf=true
	entry({"admin", "status", "usage"},alias("admin", "status", "usage", "details"),_("Usage"), 80)
	entry({"admin", "status", "usage", "details"},template("wrtbwmon"),_("Details"), 10)
	entry({"admin", "status", "usage", "config"},arcombine(cbi("wrtbwmon/config")),_("Configuration"), 20)
	entry({"admin", "status", "usage", "custom"},form("wrtbwmon/custom"),_("User file"), 30)

end

