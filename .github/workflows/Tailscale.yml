#!/bin/sh

# 1. 安装二进制文件
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# 2. 安装 LuCI 界面文件 (菜单和 HTML)
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /usr/lib/lua/luci/view/tailscale_web/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 3. 安装后端 API (这是解决“死界面”的关键)
mkdir -p /www/cgi-bin
# 这里的路径必须和 .yml 打包时的路径对应
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/tailscale_api
chmod 755 /www/cgi-bin/tailscale_api

# 4. 确保 tailscaled 核心服务在后台运行
cat << 'EOF' > /etc/init.d/tailscale
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1
start_service() {
    mkdir -p /etc/tailscale
    procd_open_instance
    procd_set_param command /usr/sbin/tailscaled --state=/etc/tailscale/tailscaled.state
    procd_set_param respawn
    procd_close_instance
}
EOF
chmod +x /etc/init.d/tailscale
/etc/init.d/tailscale enable
/etc/init.d/tailscale restart

# 5. 清理 LuCI 缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/
echo "安装完成！"
