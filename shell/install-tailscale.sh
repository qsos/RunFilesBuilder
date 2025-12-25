#!/bin/sh

# 1. 安装 jq 依赖（用于解析 Tailscale 状态）
opkg update && opkg install jq

# 2. 安装文件
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# 3. 安装 LuCI 界面
mkdir -p /usr/lib/lua/luci/controller/ /usr/lib/lua/luci/view/tailscale_web/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 4. 设置后端 API
mkdir -p /www/cgi-bin
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/tailscale_api
chmod 755 /www/cgi-bin/tailscale_api

# 5. 启动服务逻辑
/etc/init.d/tailscale stop 2>/dev/null
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

rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/
echo "安装完成，iStoreOS 风格面板已就绪。"
