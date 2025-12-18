#!/bin/sh
set -e

echo "======================================"
echo "   Tailscale Community GUI Installer  "
echo "======================================"

ARCH="$(uname -m)"
if [ "$ARCH" != "x86_64" ]; then
  echo "❌ 当前架构：$ARCH"
  echo "❌ 仅支持 x86_64"
  exit 1
fi

echo "➡ 安装 tailscale 核心程序"
install -m 0755 tailscale /usr/sbin/tailscale
install -m 0755 tailscaled /usr/sbin/tailscaled

echo "➡ 安装 LuCI 图形界面（community）"
opkg install --force-reinstall ./luci-app-tailscale-community.ipk

echo "➡ 写入 init 启动脚本（如果不存在）"
if [ ! -f /etc/init.d/tailscaled ]; then
cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
USE_PROCD=1
START=99
STOP=10

start_service() {
  procd_open_instance
  procd_set_param command /usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state
  procd_set_param respawn
  procd_close_instance
}
EOF
chmod +x /etc/init.d/tailscaled
fi

echo "➡ 启用并启动 tailscaled"
 /etc/init.d/tailscaled enable
 /etc/init.d/tailscaled restart || /etc/init.d/tailscaled start

echo "======================================"
echo "✅ 安装完成"
echo "👉 LuCI → VPN → Tailscale Community"
echo "👉 登录方式：点击「Login」→ 浏览器授权"
echo "======================================"
