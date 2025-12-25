#!/bin/sh

echo "Installing Tailscale core..."

cp tailscale /usr/sbin/tailscale
cp tailscaled /usr/sbin/tailscaled

chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

if [ ! -f /etc/init.d/tailscale ]; then
cat >/etc/init.d/tailscale <<'EOF'
#!/bin/sh /etc/rc.common
START=95
STOP=10

start() {
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

echo "Tailscale installed. Run: tailscale up"
