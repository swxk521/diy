-- LuCI CBI model for natmap
-- Converted from 23.05 JS view to 18.06 Lua CBI

local fs   = require "nixio.fs"
local util = require "luci.util"

-- 读取 /var/run/natmap/<pid>.json 获取运行状态
-- natmap-update.sh 写入：json_add_string ip / json_add_int port / inner_port / protocol
local function get_natmap_status()
	local status = {}
	local pid_dir = "/var/run/natmap/"
	local files = fs.dir(pid_dir)
	if files then
		for fname in files do
			if fname:match("%.json$") then
				local content = fs.readfile(pid_dir .. fname)
				if content then
					local ip   = content:match('"ip"%s*:%s*"([^"]+)"')
					local port = content:match('"port"%s*:%s*(%d+)')
					local pid  = fname:match("^(%d+)%.json$")
					if pid then
						status[pid] = { ip = ip, port = port }
					end
				end
			end
		end
	end
	return status
end

-- 通过 ubus 获取 procd 中 natmap 各实例的 pid -> section_name 映射
-- procd_open_instance "$1" 中 $1 即 UCI section name，与 ubus instances key 一致
local function get_pid_map()
	local map = {}
	local ok, res = pcall(util.ubus, "service", "list", { name = "natmap" })
	if ok and type(res) == "table"
		and res.natmap
		and res.natmap.instances then
		for name, inst in pairs(res.natmap.instances) do
			if inst.running and inst.pid then
				map[tostring(inst.pid)] = name
			end
		end
	end
	return map
end

local _status     = get_natmap_status()
local _pid_map    = get_pid_map()
local _sec_status = {}
for pid, info in pairs(_status) do
	local sname = _pid_map[pid]
	if sname then
		_sec_status[sname] = info
	end
end

-- 读取 UCI 逻辑接口名（与 init 脚本 network_get_device 调用一致）
local function get_network_interfaces()
	local ifaces = {}
	local uci = require("luci.model.uci").cursor()
	uci:foreach("network", "interface", function(s)
		if s[".name"] ~= "loopback" then
			ifaces[#ifaces + 1] = s[".name"]
		end
	end)
	return ifaces
end

-- ============================================================
m = Map("natmap", translate("NATMap"))

s = m:section(TypedSection, "natmap")
s.addremove = true
s.anonymous = true
s.template  = "cbi/tblsection"

-- Enable
o = s:option(Flag, "enable", translate("Enable"))
o.default = o.enabled
o.rmempty = false

-- Protocol（udp_mode: 0=TCP, 1=UDP）
o = s:option(ListValue, "udp_mode", translate("Protocol"))
o.default = "1"
o:value("0", "TCP")
o:value("1", "UDP")

-- Address family
o = s:option(ListValue, "family", translate("Restrict to address family"))
o:value("",     translate("IPv4 and IPv6"))
o:value("ipv4", translate("IPv4 only"))
o:value("ipv6", translate("IPv6 only"))

-- Interface（UCI 逻辑接口名，init 脚本用 network_get_device 转成物理名）
o = s:option(ListValue, "interface", translate("Interface"))
o:value("", translate("-- please select --"))
for _, iface in ipairs(get_network_interfaces()) do
	o:value(iface, iface)
end
o.optional = true
o.rmempty  = true

-- Keep-alive interval
o = s:option(Value, "interval", translate("Keep-alive interval"))
o.datatype = "uinteger"
o.optional = true
o.rmempty  = true

-- STUN server
o = s:option(Value, "stun_server", translate("STUN server"))
o.datatype = "host"
o.rmempty  = false

-- HTTP server（仅 TCP 模式需要）
o = s:option(Value, "http_server", translate("HTTP server"),
	translate("For TCP mode"))
o.datatype = "host"
o.optional = true
o.rmempty  = true

-- Bind port
o = s:option(Value, "port", translate("Bind port"))
o.datatype = "port"
o.rmempty  = false

-- Forward target（有值 init 脚本才会加 -t/-p 参数）
o = s:option(Value, "forward_target", translate("Forward target"))
o.datatype = "host"
o.optional = true
o.rmempty  = true

-- Forward target port
o = s:option(Value, "forward_port", translate("Forward target port"))
o.datatype = "port"
o.optional = true
o.rmempty  = true

-- Notify script（传给 natmap-update.sh 的 NOTIFY_SCRIPT 环境变量）
o = s:option(Value, "notify_script", translate("Notify script"))
o.datatype = "file"
o.optional = true
o.rmempty  = true

-- Log stdout
o = s:option(Flag, "log_stdout", translate("Log stdout"))
o.default = o.enabled
o.rmempty = false

-- Log stderr
o = s:option(Flag, "log_stderr", translate("Log stderr"))
o.default = o.enabled
o.rmempty = false

-- External IP（只读，运行时由 natmap-update.sh 写入 /var/run/natmap/<pid>.json）
o = s:option(DummyValue, "_external_ip", translate("External IP"))
function o.cfgvalue(self, section_id)
	local st = _sec_status[section_id]
	return (st and st.ip) or "-"
end

-- External Port
o = s:option(DummyValue, "_external_port", translate("External Port"))
function o.cfgvalue(self, section_id)
	local st = _sec_status[section_id]
	return (st and st.port) or "-"
end

return m
