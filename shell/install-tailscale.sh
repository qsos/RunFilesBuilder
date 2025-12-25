#!/bin/sh

echo ">>> 开始安装 Tailscale 控制台版..."

# 1. 检查并安装核心依赖 jq
if ! command -v jq >/dev/null 2>&1; then
    echo "正在安装 jq 依赖..."
    opkg update && opkg install jq
fi

# 2. 安装二进制程序
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# 3. 安装 LuCI 界面
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /usr/lib/lua/luci/view/tailscale_web/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 4. 安装后端 API 并强制设置权限
mkdir -p /www/cgi-bin
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/tailscale_api
chmod 755 /www/cgi-bin/tailscale_api

# 5. 配置并启动后台守护进程
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

# 6. 刷新页面缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/

echo "-------------------------------------------------------"
echo "✅ 安装成功！"
echo "请刷新 OpenWrt 页面，在 [服务] 菜单中进入 [Tailscale Console]。"
echo "如果界面加载缓慢，请按 Ctrl+F5 强制刷新。"
echo "-------------------------------------------------------"
