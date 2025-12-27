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

# 4. 立即激活并后台启动 (解决你现在的"连接中"问题)
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start
sleep 2

# 5. 设置环境变量以允许认证 (重要！)
if [ -f /etc/tailscale/tailscaled.state ]; then
    echo "已检测到现有配置，无需重置"
else
    echo "正在初始化 Tailscale..."
    # 首次运行时设置一些参数
    /bin/tailscaled --port 41641 --state /etc/tailscale/tailscaled.state &
    sleep 3
fi

# 6. 创建配置文件目录并设置权限
mkdir -p /etc/tailscale
chmod 755 /etc/tailscale

# 7. 清理临时文件并重启服务
rm -rf /tmp/luci-*
/etc/init.d/tailscaled restart

echo "安装成功！请刷新浏览器页面。"
echo "注意：首次使用请点击'一键登录'按钮，然后扫描二维码或点击链接完成认证。"
