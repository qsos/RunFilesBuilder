#!/bin/sh
set -e

echo "========================================"
echo "  Installing Tailscale (GUI Edition)"
echo "========================================"

cd "$(dirname "$0")"

echo "[1/4] Stop existing service (if any)"
/etc/init.d/tailscale stop 2>/dev/null || true

echo "[2/4] Install tailscale core"
opkg install ./tailscale_*.ipk --force-reinstall

echo "[3/4] Install LuCI GUI"
opkg install ./luci-app-tailscale-community_*.ipk --force-reinstall

echo "[4/4] Enable and start service"
/etc/init.d/tailscale enable
/etc/init.d/tailscale start

echo "----------------------------------------"
echo " Installation complete"
echo " LuCI path: Services → Tailscale"
echo "----------------------------------------"
