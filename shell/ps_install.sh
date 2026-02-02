#!/bin/sh

echo "======================================"
echo " PassWall Installer (.run)"
echo "======================================"

# 必须是 OpenWrt / iStoreOS
if [ ! -f /etc/openwrt_release ]; then
  echo "❌ 当前系统不是 OpenWrt / iStoreOS，退出"
  exit 1
fi

# 读取系统信息
. /etc/openwrt_release
RELEASE="${DISTRIB_RELEASE%.*}"
ARCH="$DISTRIB_ARCH"

echo "▶ 系统版本: $DISTRIB_RELEASE"
echo "▶ 架构: $ARCH"

echo "--------------------------------------"
echo "1️⃣ 添加 PassWall opkg key"
echo "--------------------------------------"

wget -O /tmp/passwall.pub \
  https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub

if [ $? -ne 0 ]; then
  echo "❌ 下载 passwall.pub 失败"
  exit 1
fi

opkg-key add /tmp/passwall.pub

echo "--------------------------------------"
echo "2️⃣ 写入 PassWall feed"
echo "--------------------------------------"

FEED_FILE="/etc/opkg/customfeeds.conf"

grep -q passwall_luci "$FEED_FILE" 2>/dev/null || cat >> "$FEED_FILE" <<EOF

src/gz passwall_luci https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$RELEASE/$ARCH/passwall_luci
src/gz passwall_packages https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$RELEASE/$ARCH/passwall_packages
EOF

echo "--------------------------------------"
echo "3️⃣ 更新 opkg"
echo "--------------------------------------"

opkg update

echo "--------------------------------------"
echo "4️⃣ 安装 PassWall"
echo "--------------------------------------"

opkg install luci-app-passwall

echo "--------------------------------------"
echo "5️⃣ 安装中文语言包"
echo "--------------------------------------"

opkg install luci-i18n-passwall-zh-cn

echo "--------------------------------------"
echo "6️⃣ 重启 uhttpd"
echo "--------------------------------------"

/etc/init.d/uhttpd restart

echo "======================================"
echo " ✅ PassWall 安装完成"
echo " 👉 LuCI 菜单：服务 → PassWall"
echo "======================================"

exit 0
