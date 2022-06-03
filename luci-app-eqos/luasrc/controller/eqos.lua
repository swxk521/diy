module("luci.controller.eqos", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/eqos") then return end
	entry({"admin", "services", "eqos"}, cbi("eqos"), _("EQoS"),150).dependent = true
end
