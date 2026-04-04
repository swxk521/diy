-- LuCI CBI model for natmap (OpenWrt 18.06 compatible)
-- Ported from JS view (23.05) to Lua CBI (18.06)

local fs   = require "nixio.fs"
local sys  = require "luci.sys"
local uci  = require "luci.model.uci".cursor()

-- Read natmap status from /var/run/natmap/<pid>.json
local function get_status()
	local status = {}
	-- Iterate running natmap instances via procd service list
	local instances = {}
	local ok, res = pcall(function()
		local json = require "luci.jsonc"
		-- Read procd service info via ubus
		local handle = io.popen("ubus call service list '{ \"name\": \"natmap\" }' 2>/dev/null")
		if handle then
			local data = handle:read("*a")
			handle:close()
			if data and #data > 0 then
				local obj = json.parse(data)
				if obj and obj.natmap and obj.natmap.instances then
					instances = obj.natmap.instances
				end
			end
		end
	end)

	for key, inst in pairs(instances) do
		if inst.running and inst.pid then
			local f = "/var/run/natmap/" .. inst.pid .. ".json"
			local content = fs.readfile(f)
			if content then
				local ok2, parsed = pcall(function()
					local json = require "luci.jsonc"
					return json.parse(content)
				end)
				if ok2 and parsed then
					status[key] = parsed
				end
			end
		end
	end
	return status
end

local status = get_status()

-- ──────────────────────────────────────────────
m = Map("natmap", translate("NATMap"))
-- ──────────────────────────────────────────────

s = m:section(TypedSection, "natmap", translate("NATMap Instances"))
s.addremove = true
s.anonymous = true
s.template  = "cbi/tblsection"

-- Enable
local o_enable = s:option(Flag, "enable", translate("Enable"))
o_enable.default = o_enable.enabled

-- Protocol (udp_mode)
local o_proto = s:option(ListValue, "udp_mode", translate("Protocol"))
o_proto.default = "1"
o_proto:value("0", "TCP")
o_proto:value("1", "UDP")

-- Address family (modal only equivalent: show always in 18.06)
local o_family = s:option(ListValue, "family", translate("Restrict to address family"))
o_family:value("", translate("IPv4 and IPv6"))
o_family:value("ipv4", translate("IPv4 only"))
o_family:value("ipv6", translate("IPv6 only"))

-- Interface
local o_iface = s:option(ListValue, "interface", translate("Interface"))
o_iface.template = "cbi/network_ifacelist"
o_iface.widget   = "select"
o_iface.nocreate = true
-- populate with available interfaces
uci:foreach("network", "interface", function(sec)
	if sec[".name"] ~= "loopback" then
		o_iface:value(sec[".name"], sec[".name"])
	end
end)
o_iface.optional = true
o_iface.rmempty  = true

-- Keep-alive interval
local o_interval = s:option(Value, "interval", translate("Keep-alive interval"))
o_interval.datatype = "uinteger"
o_interval.optional  = true
o_interval.rmempty   = true

-- STUN server
local o_stun = s:option(Value, "stun_server", translate("STUN server"))
o_stun.datatype = "host"
o_stun.rmempty  = false

-- HTTP server (TCP mode)
local o_http = s:option(Value, "http_server", translate("HTTP server"),
	translate("For TCP mode"))
o_http.datatype = "host"
o_http.rmempty  = true
o_http:depends("udp_mode", "0")

-- Bind port
local o_port = s:option(Value, "port", translate("Bind port"))
o_port.datatype = "port"
o_port.rmempty  = false

-- Forward mode (checkbox that gates forward_target/forward_port)
local o_fwd_mode = s:option(Flag, "_forward_mode", translate("Forward mode"))
o_fwd_mode.ucioption = "forward_target"
-- load: non-empty forward_target → checked
function o_fwd_mode.cfgvalue(self, section)
	local v = m.uci:get("natmap", section, "forward_target")
	return (v and #v > 0) and self.enabled or self.disabled
end
-- write: only a display flag, actual value written by forward_target
function o_fwd_mode.write() end
function o_fwd_mode.remove() end

-- Forward target
local o_ftarget = s:option(Value, "forward_target", translate("Forward target"))
o_ftarget.datatype = "host"
o_ftarget.optional = true
o_ftarget.rmempty  = true
o_ftarget:depends("_forward_mode", "1")

-- Forward target port
local o_fport = s:option(Value, "forward_port", translate("Forward target port"))
o_fport.datatype = "port"
o_fport.optional = true
o_fport.rmempty  = true
o_fport:depends("_forward_mode", "1")

-- Notify script
local o_notify = s:option(Value, "notify_script", translate("Notify script"))
o_notify.optional = true
o_notify.rmempty  = true

-- External IP (read-only status, shown in table)
local o_extip = s:option(DummyValue, "_external_ip", translate("External IP"))
function o_extip.cfgvalue(self, section)
	local st = status[section]
	return st and st.ip or "--"
end

-- External Port (read-only status, shown in table)
local o_extport = s:option(DummyValue, "_external_port", translate("External Port"))
function o_extport.cfgvalue(self, section)
	local st = status[section]
	return st and tostring(st.port) or "--"
end

return m
