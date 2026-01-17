#!/bin/bash

# 创建存放目录
mkdir -p ipk

# 定义资源地址 (使用 chenmozhijin 官方 package 分支)
BASE_URL="https://github.com/chenmozhijin/turboacc/raw/package/packages/x86_64"

echo "Step 1: 正在下载所有核心组件..."
# 下载列表：包含界面、翻译、FullCone、以及修改过的防火墙核心
PKGS=(
    "luci-app-turboacc_1.0-1_all.ipk"
    "luci-i18n-turboacc-zh-cn_1.0-1_all.ipk"
    "nft-fullcone_1.0-1_x86_64.ipk"
    "firewall4_2023-10-21-db9178ad-1_x86_64.ipk"
    "libnftnl_1.2.6-1_x86_64.ipk"
    "nftables_1.0.8-1_x86_64.ipk"
)

for pkg in "${PKGS[@]}"; do
    wget -t 3 -T 10 -c "$BASE_URL/$pkg" -P ./ipk/
    if [ $? -ne 0 ]; then echo "下载 $pkg 失败，请检查链接！"; exit 1; fi
done

echo "Step 2: 生成终极安装脚本..."
cat << 'EOF' > install.sh
#!/bin/sh
# 强制输出到控制台
exec 1> /dev/console
exec 2> /dev/console

PKG_DIR=$(cd $(dirname $0); pwd)
echo "------------------------------------------------"
echo "  TurboAcc 终极安装程序开始 (iStoreOS 专用版)"
echo "------------------------------------------------"

# 1. 临时允许不匹配的内核模块安装
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf

# 2. 强制安装所有内置 IPK
# --force-depends: 忽略内核版本不一致 (Magic Hash 差异)
# --force-overwrite: 覆盖 iStoreOS 自带的防火墙文件
# --force-checksum: 忽略校验错误
cd "$PKG_DIR/ipk"
echo "正在执行暴力安装..."
opkg install *.ipk --force-depends --force-overwrite --force-checksum --force-maintainer

# 3. 修复 LuCI 权限和缓存 (解决菜单不显示)
echo "正在强制刷新 UI 菜单..."
chmod -R 755 /usr/lib/lua/luci/controller/
chmod -R 755 /usr/lib/lua/luci/view/
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache /var/luci-modulecache/*

# 4. 异步重启服务 (防止安装过程网页卡死)
echo "正在启动后台服务重启任务..."
(
    sleep 5
    /etc/init.d/rpcd restart
    /etc/init.d/uhttpd restart
    /etc/init.d/firewall restart
    # 强制重新加载界面映射
    /sbin/luci-reload
    logger -t TurboAcc "安装脚本执行完毕，菜单已强制刷新"
) &

echo "------------------------------------------------"
echo "安装指令已下发！"
echo "请等待 20 秒左右，然后手动刷新网页登录。"
echo "菜单路径：'服务' -> 'Turbo Acc' 或 '网络' -> 'Turbo Acc'"
echo "------------------------------------------------"
EOF

chmod +x install.sh
