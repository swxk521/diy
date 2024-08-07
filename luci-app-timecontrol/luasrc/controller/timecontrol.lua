module("luci.controller.timecontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/timecontrol") then return end
    entry({"admin", "services", "timecontrol"}, cbi("timecontrol"), _("Internet Time Control"), 130).dependent = true
    entry({"admin", "services", "timecontrol", "status"}, call("status")).leaf = true
end

function status()
    local e = {}
    e.status = (luci.sys.call("iptables -L FORWARD | grep TIMECONTROL >/dev/null") == 0) and (luci.sys.call("ip6tables -L FORWARD | grep TIMECONTROL >/dev/null") == 0)
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
