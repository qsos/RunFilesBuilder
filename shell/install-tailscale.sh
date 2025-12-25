#!/bin/bash

# Install Tailscale on the system
echo "Starting installation of Tailscale..."

# Copy binaries to /usr/sbin
cp tailscale /usr/sbin/
cp tailscaled /usr/sbin/

# Make the binaries executable
chmod +x /usr/sbin/tailscale /usr/sbin/tailscaled

# Start Tailscale service
tailscaled &

# Inform user that the installation is complete
echo "Tailscale installation complete."
