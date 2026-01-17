#!/bin/bash

# 1. 创建临时文件夹
mkdir -p ipk

# 2. 从作者仓库下载最新的 IPK 文件
# 注意：如果构建报错 404，请去 https://github.com/chenmozhijin/turboacc/tree/package/packages/x86_64 确认文件名是否更新
BASE_URL="https://github.com/chenmozhijin/turboacc/raw/package/packages/x86_64"

echo "正在下载插件包..."
wget "$BASE_URL/luci-app-turboacc_1.0-1_all.ipk" -P ./ipk/
wget "$BASE_URL/luci-i18n-turboacc-zh-cn_1.0-1_all.ipk" -P ./ipk/
wget "$BASE_URL/nft-fullcone_1.0-1_x86_64.ipk" -P ./ipk/
wget "$BASE_URL/firewall4_2023-10-21-db9178ad-1_x86_64.ipk" -P ./ipk/
wget "$BASE_URL/libnftnl_1.2.6-1_x86_64.ipk" -P ./ipk/
wget "$BASE_URL/nftables_1.0.8-1_x86_64.ipk" -P ./ipk/

# 3. 生成内部安装脚本 install.sh (改动核心：清理缓存和异步重启)
cat << 'EOF' > install.sh
#!/bin/sh
PKG_DIR=$(cd $(dirname $0); pwd)

echo "1/3: 准备安装环境..."
opkg update
opkg install kmod-nft-offload kmod-tcp-bbr

echo "2/3: 强制安装插件包..."
cd $PKG_DIR/ipk
# 必须按顺序并强制重装，否则防火墙不会生效
opkg install libnftnl*.ipk nftables*.ipk --force-reinstall
opkg install nft-fullcone*.ipk
opkg install firewall4*.ipk --force-reinstall
opkg install luci-app-turboacc*.ipk luci-i18n-turboacc-zh-cn*.ipk

echo "3/3: 刷新系统界面..."
# 改动点：清理菜单索引缓存，否则不显示菜单
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

# 改动点：后台异步重启服务，防止网页直接断开连接
(/etc/init.d/rpcd restart && /etc/init.d/firewall restart) >/dev/null 2>&1 &

echo "安装已成功完成！"
echo "请等待 10-15 秒待防火墙重启后，手动刷新页面即可看到菜单。"
EOF

# 4. 生成内部卸载脚本 uninstall.sh
cat << 'EOF' > uninstall.sh
#!/bin/sh
opkg remove luci-app-turboacc luci-i18n-turboacc-zh-cn nft-fullcone
# 卸载后必须装回原版防火墙，否则路由器会断网
opkg install firewall4 --force-reinstall
/etc/init.d/rpcd restart &
EOF

chmod +x install.sh uninstall.sh
