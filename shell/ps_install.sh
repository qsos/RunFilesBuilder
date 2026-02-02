#!/bin/sh

echo "===================================="
echo "   PassWall RUN Installer"
echo "===================================="

wget -O /tmp/passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
opkg-key add /tmp/passwall.pub

. /etc/openwrt_release
release=${DISTRIB_RELEASE%.*}
arch=${DISTRIB_ARCH}

cat >> /etc/opkg/customfeeds.conf << EOF
src/gz passwall_luci https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/passwall_luci
src/gz passwall_packages https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/passwall_packages
EOF

opkg update
opkg install luci-app-passwall
opkg install luci-i18n-passwall-zh-cn

/etc/init.d/uhttpd restart

echo "PassWall install finished"
