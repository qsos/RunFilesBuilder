#!/bin/sh

# 1. 暴力清理旧进程
killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null

# 2. 强行分发文件 (覆盖所有可能路径)
mkdir -p /bin /usr/sbin /www/cgi-bin /usr/lib/lua/luci/view/tailscale_web
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/
chmod +x /bin/tailscale* /usr/sbin/tailscale* /www/cgi-bin/tailscale_api

# 3. 核心修复：重写服务的自启动脚本，确保路径 100% 正确
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

# 4. 立即激活并后台启动 (解决你现在的“连接中”问题)
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start
rm -rf /tmp/luci-*

echo "Success! Please refresh your browser."
