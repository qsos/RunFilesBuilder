#!/bin/sh

# Tailscale Installer Script
# Author: qsos
# Date: 2025-02-05

# Set install path
INSTALL_PATH="/usr/sbin"
CONFIG_PATH="/etc/config"
INIT_PATH="/etc/init.d"
LUCI_Controller_PATH="/usr/lib/lua/luci/controller"
LUCI_View_PATH="/usr/lib/lua/luci/view/tailscale_web"
LOG_FILE="/tmp/tailscale_install.log"

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# 1. Install Core Binaries
log ">>> 1. Installing Core Binaries..."
if [ -f "bin/tailscale" ] && [ -f "bin/tailscaled" ]; then
    cp -f bin/tailscale "$INSTALL_PATH/tailscale"
    cp -f bin/tailscaled "$INSTALL_PATH/tailscaled"
    chmod +x "$INSTALL_PATH/tailscale" "$INSTALL_PATH/tailscaled"
    log "Core binaries installed successfully."
else
    log "Error: Core binaries missing!"
    exit 1
fi

# 2. Install Simple GUI Redirector
log ">>> 2. Installing Simple GUI Redirector..."
if [ -d "usr" ]; then
    # Create target directories if they don't exist
    mkdir -p "$LUCI_Controller_PATH"
    mkdir -p "$LUCI_View_PATH"

    # Copy files
    cp -rf usr/* /usr/
    log "GUI files copied."
else
    log "Warning: GUI files directory 'usr' not found. Skipping GUI installation."
fi

# 3. Configure System & Boot
log ">>> 3. Configuring System & Boot..."

# Create config file if not exists
if [ ! -f "$CONFIG_PATH/tailscale" ]; then
    touch "$CONFIG_PATH/tailscale"
    log "Config file created."
fi

# Configure Web UI auto-start in rc.local
log "Configuring Web UI auto-start..."
sed -i '/tailscale web/d' /etc/rc.local
# Insert before 'exit 0'
if grep -q "exit 0" /etc/rc.local; then
    sed -i '/exit 0/i /usr/sbin/tailscale web --listen=0.0.0.0:5252 > /dev/null 2>&1 &' /etc/rc.local
else
    echo "/usr/sbin/tailscale web --listen=0.0.0.0:5252 > /dev/null 2>&1 &" >> /etc/rc.local
fi

# Start Web UI immediately
$INSTALL_PATH/tailscale web --listen=0.0.0.0:5252 > /dev/null 2>&1 &
log "Web UI started."

# Clear LuCI cache
log "Clearing LuCI cache..."
rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/

# Create standard service script (procd init)
log "Creating init script..."
cat << 'EOF_SVC' > "$INIT_PATH/tailscale"
#!/bin/sh /etc/rc.common
START=99
STOP=01
USE_PROCD=1

start_service() {
    # Ensure state directories exist
    mkdir -p /etc/tailscale /var/run/tailscale

    procd_open_instance
    procd_set_param command /usr/sbin/tailscaled
    # State file in /etc to persist across reboots
    procd_set_param args --state=/etc/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock --port=41641
    # Auto respawn on failure
    procd_set_param respawn
    # Redirect stdout/stderr to syslog
    procd_set_param stdout 1
    procd_set_param stderr 1
    procd_close_instance
}
EOF_SVC
chmod +x "$INIT_PATH/tailscale"

# Enable and restart service
log "Enabling and starting service..."
"$INIT_PATH/tailscale" enable
"$INIT_PATH/tailscale" restart

log "======================================================="
log "✅ Installation Complete!"
log "Please refresh your browser (Ctrl+F5)."
log "Menu location: Services -> Tailscale Web"
log "Installation log saved to: $LOG_FILE"
log "======================================================="
