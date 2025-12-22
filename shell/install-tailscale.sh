#!/bin/sh
set -e

echo "============================="
echo "安装 Tailscale 核心二进制..."
echo "============================="

# 安装核心二进制
opkg install tailscaled tailscale || true

echo "============================="
echo "安装 LuCI 界面..."
echo "============================="

# 安装现有 LuCI ipk
opkg install luci-app-tailscale_1.2.6-r19_all.ipk || true

echo "============================="
echo "重启 uhttpd 服务..."
echo "============================="
/etc/init.d/uhttpd restart

echo "============================="
echo "启动 tailscaled 服务..."
echo "============================="
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state \
                     --socket=/var/run/tailscale/tailscaled.sock &
sleep 2

echo "安装完成，Tailscale 内核已升级，LuCI 界面保留。"
