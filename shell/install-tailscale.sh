#!/bin/sh

# 1. 彻底清理旧进程和旧状态
killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null
rm -rf /etc/tailscale/tailscaled.state

# 2. 强行分发文件
mkdir -p /bin /usr/sbin /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/tailscale_web
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 3. 【核心修复 404】授予最高执行权限
chmod 755 /www/cgi-bin/tailscale_api
chmod 755 /bin/tailscale*
chmod 755 /usr/sbin/tailscale*

# 4. 写入自启动脚本
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

# 5. 激活并启动
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# 6. 【解决 404 的关键步】重启网页服务器并强制清理 LuCI 所有缓存
/etc/init.d/uhttpd restart
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/*

echo "Success! Please refresh your browser."
