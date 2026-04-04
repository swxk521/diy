module("luci.controller.natmap", package.seeall)

local fs = require "nixio.fs"

function index()
	if not fs.access("/etc/config/natmap") then
		return
	end

	local page = entry({"admin", "services", "natmap"}, cbi("natmap"), _("NATMap"), 110)
	page.dependent = true
end
