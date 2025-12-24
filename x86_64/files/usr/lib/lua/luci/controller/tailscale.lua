module("luci.controller.tailscale", package.seeall)

function index()
  entry({"admin","services","tailscale"}, call("page"), _("Tailscale"), 90)
end

function page()
  luci.template.render("tailscale/index")
end
