#!/bin/sh
# Tailscale .run installer script
# Version: 1.92.3

set -e

PREFIX=/usr/local
BIN_DIR="$PREFIX/bin"
VAR_DIR="/var/lib/tailscale"

echo "==> Installing Tailscale 1.92.3"

mkdir -p "$BIN_DIR"
mkdir -p "$VAR_DIR"

install -m 0755 tailscaled "$BIN_DIR/tailscaled"
install -m 0755 tailscale  "$BIN_DIR/tailscale"

if command -v systemctl >/dev/null 2>&1; then
    echo "==> Installing systemd service"
    install -m 0644 tailscaled.service /etc/systemd/system/tailscaled.service
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable tailscaled
    systemctl restart tailscaled
else
    echo "==> systemd not found, skipping service install"
fi

echo
echo "Tailscale installed successfully."
echo "Run: tailscale up"
