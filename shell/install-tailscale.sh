#!/bin/sh

set -e

echo "========================================"
echo "开始安装 Tailscale 控制面板"
echo "========================================"

# 1. 清理旧进程
echo "步骤 1/7: 清理旧进程..."
killall -9 tailscale tailscaled 2>/dev/null || true
/etc/init.d/tailscaled stop 2>/dev/null || true
sleep 2

# 2. 创建必要的目录结构
echo "步骤 2/7: 创建目录结构..."
mkdir -p /bin /usr/sbin /www/cgi-bin /usr/lib/lua/luci/view/tailscale_web
mkdir -p /etc/tailscale /var/run/tailscale
chmod 755 /etc/tailscale /var/run/tailscale

# 3. 安装二进制文件
echo "步骤 3/7: 安装二进制文件..."
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled

# 4. 安装 Web 界面文件
echo "步骤 4/7: 安装 Web 界面文件..."
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

# 5. 设置正确的权限
echo "步骤 5/7: 设置文件权限..."
chmod 755 /bin/tailscale /bin/tailscaled
chmod 755 /usr/sbin/tailscale /usr/sbin/tailscaled
chmod 755 /www/cgi-bin/tailscale_api
chmod 644 /usr/lib/lua/luci/controller/tailscale_web.lua
chmod 644 /usr/lib/lua/luci/view/tailscale_web/index.htm

# 6. 创建服务配置文件
echo "步骤 6/7: 配置服务..."
cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /bin/tailscaled \
        --state=/etc/tailscale/tailscaled.state \
        --socket=/var/run/tailscale/tailscaled.sock \
        --port=41641
    procd_set_param respawn
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}
EOF

chmod 755 /etc/init.d/tailscaled

# 7. 启动服务和初始化
echo "步骤 7/7: 启动服务..."

# 启用服务
/etc/init.d/tailscaled enable

# 创建初始状态文件（如果不存在）
if [ ! -f /etc/tailscale/tailscaled.state ]; then
    echo "初始化状态文件..."
    touch /etc/tailscale/tailscaled.state
    chmod 600 /etc/tailscale/tailscaled.state
fi

# 启动服务
echo "启动 tailscaled 服务..."
/etc/init.d/tailscaled start

# 等待服务启动
echo "等待服务启动..."
for i in $(seq 1 10); do
    if pgrep tailscaled > /dev/null 2>&1; then
        echo "✓ tailscaled 服务已启动"
        break
    fi
    echo "等待中... ($i/10)"
    sleep 1
done

# 重启 Web 服务器
echo "重启 Web 服务器..."
if [ -f /etc/init.d/uhttpd ]; then
    /etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/uhttpd reload 2>/dev/null || true
fi

# 清理临时文件
rm -rf /tmp/luci-*

echo ""
echo "========================================"
echo "安装完成！"
echo "========================================"
echo ""
echo "现在你可以："
echo "1. 刷新浏览器页面"
echo "2. 进入 服务 → Tailscale"
echo "3. 点击'一键登录'按钮开始使用"
echo ""
echo "如果登录失败，请检查："
echo "- 系统日志: logread | grep tailscale"
echo "- API 日志: cat /tmp/tailscale_api.log"
echo "========================================"

# 等待2秒再检查一次服务状态
sleep 2
if pgrep tailscaled > /dev/null 2>&1; then
    echo "✓ 服务运行正常"
else
    echo "⚠️ 服务可能未启动，请手动执行: /etc/init.d/tailscaled start"
fi
