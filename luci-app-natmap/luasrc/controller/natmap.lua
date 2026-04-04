module("luci.controller.natmap", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/natmap") then
		return
	end

	local page = entry({"admin", "services", "natmap"}, cbi("natmap"), _("NATMap"), 60)
	page.dependent = true
	page.acl_depends = { "luci-app-natmap" }
end
