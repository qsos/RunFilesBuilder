#!/bin/sh

killall -9 tailscale tailscaled 2>/dev/null
/etc/init.d/tailscaled stop 2>/dev/null

mkdir -p /bin /usr/sbin /www/cgi-bin \
         /usr/lib/lua/luci/controller \
         /usr/lib/lua/luci/view/tailscale_web

cp -f bin/tailscale /bin/
cp -f bin/tailscaled /bin/
cp -f bin/tailscale /usr/sbin/
cp -f bin/tailscaled /usr/sbin/

cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/tailscale_web/index.htm /usr/lib/lua/luci/view/tailscale_web/

chmod +x /bin/tailscale* /usr/sbin/tailscale* /www/cgi-bin/tailscale_api

cat << 'EOF' > /etc/init.d/tailscaled
#!/bin/sh /etc/rc.common
START=99
USE_PROCD=1
start_service() {
  procd_open_instance
  procd_set_param command /bin/tailscaled --state /etc/tailscale/tailscaled.state
  procd_set_param respawn
  procd_close_instance
}
EOF

chmod +x /etc/init.d/tailscaled
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/*
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart

echo "Success"
