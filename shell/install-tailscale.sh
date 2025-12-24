#!/bin/sh

echo "== Installing Tailscale core =="

INSTALL_DIR=/usr/sbin

cp tailscale "$INSTALL_DIR/tailscale"
cp tailscaled "$INSTALL_DIR/tailscaled"

chmod +x "$INSTALL_DIR/tailscale" "$INSTALL_DIR/tailscaled"

if [ ! -f /etc/init.d/tailscale ]; then
cat >/etc/init.d/tailscale <<'EOF'
#!/bin/sh /etc/rc.common
START=95
STOP=10

start() {
    echo "Starting tailscaled..."
    /usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state &
}

stop() {
    killall tailscaled 2>/dev/null
}
EOF
chmod +x /etc/init.d/tailscale
/etc/init.d/tailscale enable
fi

/etc/init.d/tailscale start

echo
echo "Tailscale installed."
echo "Run this in LuCI or SSH once to login:"
echo "tailscale up"
