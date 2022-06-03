module("luci.controller.timecontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/timecontrol") then return end
    entry({"admin", "services", "timecontrol"}, cbi("timecontrol"), _("Time control"), 200).dependent = true
end

