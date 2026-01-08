#!/bin/bash
# 02-drivers-macbook.sh - MacBook 10,1 specific drivers
# Handles Broadcom WiFi, Intel graphics, and Apple hardware quirks

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing MacBook 10,1 Drivers"

# Verify we're on MacBook hardware
if ! is_macbook; then
    log_warn "Not running on MacBook hardware."
    log_info "Use 03-drivers-generic.sh instead."
    exit 0
fi

log_success "MacBook hardware detected!"

# Intel microcode
log_step "Installing Intel CPU microcode..."
apt_install intel-microcode

# Intel graphics (i915 is built into kernel, but ensure Mesa is there)
log_step "Ensuring Intel graphics support..."
apt_install \
    libgl1-mesa-dri \
    mesa-vulkan-drivers \
    intel-media-va-driver

# Broadcom WiFi (BCM4350)
if has_broadcom_wifi; then
    log_step "Installing Broadcom WiFi driver (BCM4350)..."
    apt_install bcmwl-kernel-source

    # Copy blacklist configuration
    REPO_DIR="$(get_repo_dir)"
    if [ -f "$REPO_DIR/dotfiles/etc/modprobe.d/broadcom-sta-dkms.conf" ]; then
        log_step "Installing WiFi driver blacklist config..."
        sudo cp "$REPO_DIR/dotfiles/etc/modprobe.d/broadcom-sta-dkms.conf" /etc/modprobe.d/
        log_success "WiFi blacklist config installed"
    fi

    # Update initramfs to apply driver changes
    log_step "Updating initramfs..."
    sudo update-initramfs -u

    log_success "Broadcom WiFi driver installed!"
    log_warn "A reboot is required to activate the WiFi driver."
else
    log_info "No Broadcom WiFi detected, skipping wl driver."
fi

# Apple-specific firmware
log_step "Checking for Apple firmware..."
apt_install linux-firmware

log_success "MacBook drivers installed!"
log_warn "Please reboot to apply all driver changes."
