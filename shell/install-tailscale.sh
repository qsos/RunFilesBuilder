#!/bin/sh

# 1. 暴力清理旧进程，防止后台死锁
killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null

# 2. 强行分发文件 (覆盖所有可能路径，确保 API 和 UI 都能找到)
mkdir -p /bin /usr/sbin /www/cgi-bin /usr/lib/lua/luci/controller /usr/lib/lua/luci/view/tailscale_web
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 3. 核心修复：授予 CGI 脚本和二进制文件执行权限，防止 404/403
chmod 755 /www/cgi-bin/tailscale_api
chmod 755 /bin/tailscale*
chmod 755 /usr/sbin/tailscale*
chmod -R 755 /usr/lib/lua/luci/view/tailscale_web

# 4. 重写自启动脚本
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

# 5. 立即激活并启动服务
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

# 6. 【解决 404 的关键】强制重启 Web 服务并清理 LuCI 索引缓存
/etc/init.d/uhttpd restart
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/*

echo "Success! Please refresh your browser."
