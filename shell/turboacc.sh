#!/bin/bash

# 1. 创建临时存放 ipk 的目录
mkdir -p ipk

# 2. 定义下载链接 (这里以 x86_64 为例，从 chenmozhijin 的 package 分支抓取)
# 注意：这些链接需要是直链。如果版本更新，请手动更新这里的链接
BASE_URL="https://github.com/chenmozhijin/turboacc/raw/package/packages/x86_64"

echo "正在从远程仓库获取 IPK 文件..."
wget $BASE_URL/luci-app-turboacc_1.0-1_all.ipk -P ./ipk/
wget $BASE_URL/luci-i18n-turboacc-zh-cn_1.0-1_all.ipk -P ./ipk/
wget $BASE_URL/nft-fullcone_1.0-1_x86_64.ipk -P ./ipk/
wget $BASE_URL/firewall4_2023-10-21-db9178ad-1_x86_64.ipk -P ./ipk/

# 3. 生成插件内部的安装脚本 install.sh
cat << 'EOF' > install.sh
#!/bin/sh
PKG_DIR=$(cd $(dirname $0); pwd)
echo "正在安装 TurboAcc 及其依赖..."
opkg update
opkg install kmod-nft-offload kmod-tcp-bbr
cd $PKG_DIR/ipk
opkg install *.ipk --force-reinstall
rm -rf /tmp/luci-modulecache
/etc/init.d/rpcd restart
echo "安装成功！"
EOF

# 4. 生成插件内部的卸载脚本 uninstall.sh
cat << 'EOF' > uninstall.sh
#!/bin/sh
opkg remove luci-app-turboacc luci-i18n-turboacc-zh-cn
opkg install firewall4 --force-reinstall
EOF

# 5. 赋予执行权限
chmod +x install.sh uninstall.sh
