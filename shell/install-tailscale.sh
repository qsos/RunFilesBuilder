#!/bin/sh

# 彻底清理旧状态
killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null
rm -f /etc/tailscale/tailscaled.state

# 覆盖安装文件
mkdir -p /bin /www/cgi-bin /usr/lib/lua/luci/view/tailscale_web
cp -f bin/tailscale* /bin/
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/
chmod +x /bin/tailscale* /www/cgi-bin/tailscale_api

# 强制重写并启动服务
cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1
start_service() {
    procd_open_instance
    procd_set_param command /bin/tailscaled --port 41641 --state /etc/tailscale/tailscaled.state
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# 【精准修复 404】重启 Web 服务并强刷 LuCI 索引缓存
/etc/init.d/uhttpd restart
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/*

echo "Success! Please refresh your browser."
