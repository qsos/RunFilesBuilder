#!/bin/bash

mkdir -p ipk
BASE_URL="https://github.com/chenmozhijin/turboacc/raw/package/packages/x86_64"

echo "正在准备 IPK 文件..."
wget -c "$BASE_URL/luci-app-turboacc_1.0-1_all.ipk" -P ./ipk/
wget -c "$BASE_URL/luci-i18n-turboacc-zh-cn_1.0-1_all.ipk" -P ./ipk/
wget -c "$BASE_URL/nft-fullcone_1.0-1_x86_64.ipk" -P ./ipk/
wget -c "$BASE_URL/firewall4_2023-10-21-db9178ad-1_x86_64.ipk" -P ./ipk/
wget -c "$BASE_URL/libnftnl_1.2.6-1_x86_64.ipk" -P ./ipk/
wget -c "$BASE_URL/nftables_1.0.8-1_x86_64.ipk" -P ./ipk/

cat << 'EOF' > install.sh
#!/bin/sh
# 强制把安装过程显示在终端输出中
exec 1> /dev/console
exec 2> /dev/console

PKG_DIR=$(cd $(dirname $0); pwd)
IPK_PATH="$PKG_DIR/ipk"

echo "DEBUG: 开始强制覆盖安装 TurboAcc..."

# 1. 更新源
opkg update

# 2. 强制安装所有组件
cd "$IPK_PATH"
# --force-depends: 解决内核版本号微调不匹配
# --force-overwrite: 解决 iStoreOS 自带 firewall4 文件冲突（必选）
opkg install *.ipk --force-depends --force-overwrite --force-maintainer

# 3. 刷新菜单和重启
echo "DEBUG: 刷新 LuCI 菜单缓存..."
rm -rf /tmp/luci-*
rm -rf /var/luci-modulecache/*

# 异步后台重启服务，防止断网导致安装脚本中断
(
    sleep 3
    /etc/init.d/rpcd restart
    /etc/init.d/firewall restart
    /sbin/luci-reload
) &

echo "DEBUG: 安装指令已完成。请 15 秒后刷新网页。"
EOF

chmod +x install.sh
