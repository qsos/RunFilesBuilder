#!/bin/sh

# 停止旧服务
/etc/init.d/tailscaled stop 2>/dev/null

# 1. 强行分发二进制文件到双路径 (彻底解决“找不到执行程序”)
mkdir -p /bin /usr/sbin
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /bin/tailscale* /usr/sbin/tailscale*

# 2. 安装 UI 界面和 API 脚本 (彻底解决红框“Runtime Error”)
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /usr/lib/lua/luci/view/tailscale_web/
mkdir -p /www/cgi-bin/

cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -rf usr/lib/lua/luci/view/tailscale_web/* /usr/lib/lua/luci/view/tailscale_web/
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
chmod 755 /www/cgi-bin/tailscale_api

# 3. 核心：强制清理 LuCI 编译缓存
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

# 4. 启动服务
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

echo "Tailscale 控制面板安装成功！请 F5 刷新网页。"
