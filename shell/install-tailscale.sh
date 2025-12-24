#!/bin/sh
set -e

echo "Installing Tailscale core..."
mkdir -p /usr/sbin
cp bin/tailscale /usr/sbin/tailscale
cp bin/tailscaled /usr/sbin/tailscaled
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

echo "Installing LuCI files..."
cp -r files/* /

/etc/init.d/tailscale enable
/etc/init.d/tailscale restart || true

echo "Done. Please refresh LuCI."
