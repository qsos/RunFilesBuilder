#!/bin/sh

# 1. 停止旧服务
/etc/init.d/tailscale stop 2>/dev/null
killall -9 tailscale tailscaled 2>/dev/null

# 2. 1:1 物理路径覆盖
cp -rf usr etc www /

# 3. 赋予核心权限
chmod 755 /usr/sbin/tailscale*
chmod 755 /usr/libexec/rpcd/tailscale
chmod 755 /etc/init.d/tailscale

# 4. 重启系统接口
/etc/init.d/rpcd restart
/etc/init.d/tailscale enable
/etc/init.d/tailscale restart

# 5. 强制清空网页缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/*

echo "------------------------------------------------"
echo " 完成！内核已更新，界面完全保留官方原始逻辑。"
echo "------------------------------------------------"
