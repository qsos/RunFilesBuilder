#!/bin/sh

# 1. 安装二进制
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# 2. 安装 LuCI 界面文件
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /usr/lib/lua/luci/view/tailscale_web/
cp -rf usr/lib/lua/luci/* /usr/lib/lua/luci/

# 3. 安装 API 后端 (重要：这步实现控制功能)
mkdir -p /www/cgi-bin
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/tailscale_api
chmod +x /www/cgi-bin/tailscale_api

# 4. 设置服务自启
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

# 清理缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/
echo "安装成功！请刷新 OpenWrt 页面查看服务菜单。"
