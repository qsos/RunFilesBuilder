#!/bin/sh

echo "===================================="
echo "   PassWall RUN Installer"
echo "===================================="

# 1. 添加 opkg key
echo "[1/6] Add PassWall opkg key"
wget -O /tmp/passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
opkg-key add /tmp/passwall.pub

# 2. 添加 PassWall 官方仓库（稳定版）
echo "[2/6] Add PassWall feeds"

. /etc/openwrt_release

release=${DISTRIB_RELEASE%.*}
arch=${DISTRIB_ARCH}

cat >> /etc/opkg/customfeeds.conf << EOF
src/gz passwall_luci https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/passwall_luci
src/gz passwall_packages https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/passwall_packages
EOF

# 3. 更新索引
echo "[3/6] opkg update"
opkg update

# 4. 安装 PassWall
echo "[4/6] Install luci-app-passwall"
opkg install luci-app-passwall

# 5. 安装中文语言包
echo "[5/6] Install zh-cn language"
opkg install luci-i18n-passwall-zh-cn

# 6. 重启 Web 服务
echo "[6/6] Restart uhttpd"
/etc/init.d/uhttpd restart

echo "===================================="
echo " PassWall installation finished"
echo "===================================="
