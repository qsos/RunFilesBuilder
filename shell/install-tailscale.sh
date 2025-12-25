#!/bin/sh
# 彻底清理残留
killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null
rm -rf /etc/tailscale/tailscaled.state

# 安装文件并强制授权
mkdir -p /bin /www/cgi-bin /usr/lib/lua/luci/view/tailscale_web /usr/lib/lua/luci/controller
cp -f bin/tailscale* /bin/
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/
chmod -R 755 /bin/tailscale* /www/cgi-bin/tailscale_api /usr/lib/lua/luci/view/tailscale_web

# 重新注册服务
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
chmod 755 /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start
rm -rf /tmp/luci-*
