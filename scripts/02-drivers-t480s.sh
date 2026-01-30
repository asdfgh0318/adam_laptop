#!/bin/bash
# 02-drivers-t480s.sh - ThinkPad T480s specific drivers and optimizations
# Handles Intel graphics, WiFi firmware, fingerprint reader, ThinkPad power management

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing ThinkPad T480s Drivers & Optimizations"

# Verify we're on ThinkPad hardware
if ! is_thinkpad; then
    log_warn "Not running on ThinkPad hardware."
    log_info "Use 02-drivers-macbook.sh or 03-drivers-generic.sh instead."
    exit 0
fi

log_success "ThinkPad hardware detected!"

# Intel CPU microcode (8th gen Kaby Lake-R)
log_step "Installing Intel CPU microcode..."
apt_install intel-microcode

# Intel graphics (UHD 620 via i915, built into kernel)
log_step "Ensuring Intel graphics support (UHD 620)..."
apt_install \
    libgl1-mesa-dri \
    mesa-vulkan-drivers \
    intel-media-va-driver

# Linux firmware (includes Intel WiFi 8265 firmware)
log_step "Installing Linux firmware (Intel WiFi 8265)..."
apt_install linux-firmware

# Thermal management (Intel-specific)
log_step "Installing Intel thermal management..."
apt_install thermald
sudo systemctl enable thermald 2>/dev/null || true

# ThinkPad power management (TLP)
log_step "Installing ThinkPad power management (TLP)..."
apt_install tlp tlp-rdw

# ThinkPad battery threshold control
log_step "Installing ThinkPad battery threshold tools..."
apt_install acpi-call-dkms 2>/dev/null || {
    log_warn "acpi-call-dkms not available, battery thresholds may not work"
}

# Enable and start TLP
log_step "Enabling TLP service..."
sudo systemctl enable tlp 2>/dev/null || true
sudo systemctl start tlp 2>/dev/null || true

# Thunderbolt 3 security management
log_step "Installing Thunderbolt management..."
apt_install bolt
sudo systemctl enable bolt 2>/dev/null || true

# Fingerprint reader (optional)
if has_fingerprint_reader; then
    log_step "Fingerprint reader detected! Installing fprintd..."
    apt_install fprintd libpam-fprintd

    log_info "To enroll fingerprints, run:"
    log_info "  fprintd-enroll"
    log_info "To enable fingerprint login:"
    log_info "  sudo pam-auth-update"
else
    log_info "No fingerprint reader detected, skipping fprintd."
fi

# Set TLP ThinkPad battery thresholds for longevity
log_step "Configuring battery thresholds..."
if [ -f /etc/tlp.conf ]; then
    if ! grep -q "START_CHARGE_THRESH_BAT0=75" /etc/tlp.conf 2>/dev/null; then
        log_info "Setting battery charge thresholds (75%-80%) for longevity..."
        sudo tee -a /etc/tlp.conf > /dev/null <<'TLPEOF'

# ThinkPad T480s battery thresholds (set by adam_laptop)
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80
TLPEOF
        log_success "Battery thresholds configured (75%-80%)"
    else
        log_info "Battery thresholds already configured"
    fi
fi

log_success "ThinkPad T480s drivers and optimizations installed!"
echo ""
log_info "ThinkPad-specific features enabled:"
log_info "  - TLP power management (battery thresholds 75%-80%)"
log_info "  - Intel thermal management (thermald)"
log_info "  - Thunderbolt 3 security (bolt)"
if has_fingerprint_reader; then
    log_info "  - Fingerprint reader (fprintd)"
fi
log_warn "Please reboot to apply all changes."
