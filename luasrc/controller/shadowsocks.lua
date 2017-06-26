-- Copyright (C) 2014-2017 Jian Chang <aa65535@live.com>
-- Modified By Xingwang Liao <kuoruan@gmail.com> 2017-06-21
-- Licensed to the public under the GNU General Public License v3.

module("luci.controller.shadowsocks", package.seeall)

local http = require "luci.http"
local sys = require "luci.sys"

local ps = sys.call("ps --help 2>&1 | grep -q BusyBox") == 0 and "ps w" or "ps axw"

function index()
	if not nixio.fs.access("/etc/config/shadowsocks") then
		return
	end

	entry({"admin", "services", "shadowsocks"},
		alias("admin", "services", "shadowsocks", "general"),
		_("ShadowSocks"), 10).dependent = true

	entry({"admin", "services", "shadowsocks", "general"},
		cbi("shadowsocks/general"),
		_("General Settings"), 10).leaf = true

	entry({"admin", "services", "shadowsocks", "status"},
		call("action_status")).leaf = true

	entry({"admin", "services", "shadowsocks", "servers"},
		arcombine(cbi("shadowsocks/servers"), cbi("shadowsocks/servers-details")),
		_("Servers Manage"), 20).leaf = true

	entry({"admin", "services", "shadowsocks", "access-control"},
		cbi("shadowsocks/access-control"),
		_("Access Control"), 30).leaf = true
end

local function is_running(name)
	return sys.call("%s | grep -v grep | grep -qw %s" %{ ps, name }) == 0
end

function action_status()
	-- 0: not running  1: shadowsocks  2: shadowsocksR

	local redir_status, local_status, tunnel_status = 0, 0, 0

	if is_running("ss-redir") then
		redir_status = 1
	elseif is_running("ssr-redir") then
		redir_status = 2
	end

	if is_running("ss-local") then
		local_status = 1
	elseif is_running("ssr-local") then
		local_status = 2
	end

	if is_running("ss-tunnel") then
		tunnel_status = 1
	elseif is_running("ssr-tunnel") then
		tunnel_status = 2
	end

	http.prepare_content("application/json")
	http.write_json({
		redir_status = redir_status,
		local_status = local_status,
		tunnel_status = tunnel_status
	})
end
