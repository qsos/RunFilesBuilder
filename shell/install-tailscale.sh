#!/bin/sh

# 1. 停止旧服务
/etc/init.d/tailscaled stop 2>/dev/null

# 2. 创建官方路径
mkdir -p /usr/lib/lua/luci/controller/
mkdir -p /www/luci-static/resources/view/

# 3. 【核心步骤】将你发给我的代码保存为官方 JS 文件
# 注意：这里假设你已经把刚才发我的代码存成了仓库里的 tailscale.js
cp -f tailscale.js /www/luci-static/resources/view/tailscale.js

# 4. 创建一个“中转控制中心”，让它支持官方 JS 调用
cat << 'EOF' > /usr/lib/lua/luci/controller/tailscale.lua
module("luci.controller.tailscale", package.seeall)
function index()
    -- 注册网页菜单
    entry({"admin", "services", "tailscale"}, alias("admin", "services", "tailscale", "index"), _("Tailscale"), 99)
    entry({"admin", "services", "tailscale", "index"}, view("tailscale"), _("Tailscale"), 1)
end
EOF

# 5. 权限与重启
chmod 755 /bin/tailscale*
/etc/init.d/uhttpd restart
rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/*

echo "官方架构适配完成！请刷新页面。"
