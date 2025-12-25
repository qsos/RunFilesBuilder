#!/bin/sh

# 停止旧服务，防止文件占用
/etc/init.d/tailscaled stop 2>/dev/null

# 强行分发二进制文件到双路径 (解决“找不到执行程序”)
# staging 中的 bin 文件夹会被打包，解压时在当前目录下
cp -f bin/tailscale /bin/tailscale
cp -f bin/tailscaled /bin/tailscaled
cp -f bin/tailscale /usr/sbin/tailscale
cp -f bin/tailscaled /usr/sbin/tailscaled
chmod +x /bin/tailscale* /usr/sbin/tailscale*

# 分发 UI 界面文件 (解决红色“Runtime error”)
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /usr/lib/lua/luci/view/tailscale_web/
mkdir -p /www/cgi-bin/

cp -f usr/lib/lua/luci/controller/tailscale_web.lua /usr/lib/lua/luci/controller/
cp -rf usr/lib/lua/luci/view/tailscale_web/* /usr/lib/lua/luci/view/tailscale_web/
cp -f www/cgi-bin/tailscale_api /www/cgi-bin/
chmod 755 /www/cgi-bin/tailscale_api

# 强制刷新 LuCI 缓存，让新界面立即生效
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache

# 启动服务
/etc/init.d/tailscaled enable
/etc/init.d/tailscaled start

echo "Tailscale 安装成功！请刷新网页查看干净的控制面板。"
