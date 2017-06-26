-- Copyright (C) 2014-2017 Jian Chang <aa65535@live.com>
-- Modified By Xingwang Liao <kuoruan@gmail.com> 2017-06-21
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local shadowsocks = "shadowsocks"
local uci = require "luci.model.uci".cursor()
local servers = {}

local function has_udp_relay()
	return luci.sys.call("lsmod | grep -q TPROXY && command -v ip >/dev/null") == 0
end

uci:foreach(shadowsocks, "servers", function(s)
	if s.server and s.server_port then
		servers[#servers+1] = {name = s[".name"], alias = s.alias or "%s:%s" %{s.server, s.server_port}}
	end
end)

m = Map(shadowsocks, "%s - %s" %{translate("ShadowSocks"), translate("General Settings")})
m:append(Template("shadowsocks/status"))

s = m:section(TypedSection, "general", translate("Global Settings"))
s.anonymous = true

o = s:option(Value, "startup_delay", translate("Startup Delay"))
o:value(0, translate("Not enabled"))
for _, v in ipairs({5, 10, 15, 25, 40}) do
	o:value(v, translate("%u seconds") %{v})
end
o.datatype = "uinteger"
o.default = 0
o.rmempty = false

-- [[ Transparent Proxy ]]--
s = m:section(TypedSection, "transparent_proxy", translate("Transparent Proxy"))
s.anonymous = true

o = s:option(DynamicList, "main_server", translate("Main Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.rmempty = false

o = s:option(ListValue, "udp_relay_server", translate("UDP-Relay Server"))
if has_udp_relay() then
	o:value("nil", translate("Disable"))
	o:value("same", translate("Same as Main Server"))
	for _, s in ipairs(servers) do o:value(s.name, s.alias) end
else
	o:value("nil", translate("Unusable - Missing iptables-mod-tproxy or ip"))
end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1234
o.rmempty = false

o = s:option(Value, "mtu", translate("Override MTU"))
o.default = 1492
o.datatype = "range(296,9200)"
o.rmempty = false

-- [[ SOCKS5 Proxy ]]--
s = m:section(TypedSection, "socks5_proxy", translate("SOCKS5 Proxy"))
s.anonymous = true

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o.rmempty = false

o = s:option(Value, "mtu", translate("Override MTU"))
o.default = 1492
o.datatype = "range(296,9200)"
o.rmempty = false

-- [[ Port Forward ]]--
s = m:section(TypedSection, "port_forward", translate("Port Forward"))
s.anonymous = true

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 5300
o.rmempty = false

o = s:option(Value, "destination", translate("Destination"))
o.default = "8.8.4.4:53"
o.rmempty = false

o = s:option(Value, "mtu", translate("Override MTU"))
o.default = 1492
o.datatype = "range(296,9200)"
o.rmempty = false

return m
