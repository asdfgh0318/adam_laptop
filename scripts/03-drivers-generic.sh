#!/bin/bash
# 03-drivers-generic.sh - Generic hardware driver support
# For non-MacBook hardware (Intel, AMD, NVIDIA, various WiFi)

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing Generic Hardware Drivers"

# Common firmware
log_step "Installing Linux firmware..."
apt_install linux-firmware

# Intel graphics
if has_intel_graphics; then
    log_step "Intel GPU detected - installing drivers..."
    apt_install \
        libgl1-mesa-dri \
        mesa-vulkan-drivers \
        intel-media-va-driver \
        intel-microcode
    log_success "Intel graphics drivers installed"
fi

# AMD graphics
if has_amd_graphics; then
    log_step "AMD GPU detected - installing drivers..."
    apt_install \
        libgl1-mesa-dri \
        mesa-vulkan-drivers \
        libdrm-amdgpu1 \
        amd64-microcode
    log_success "AMD graphics drivers installed"
fi

# NVIDIA graphics
if has_nvidia_graphics; then
    log_warn "NVIDIA GPU detected!"
    log_info "For best performance, install proprietary drivers:"
    log_info "  sudo ubuntu-drivers autoinstall"
    log_info "Or manually:"
    log_info "  sudo apt install nvidia-driver-XXX"
    log_info ""
    log_info "For now, installing open-source nouveau support..."
    apt_install \
        libgl1-mesa-dri \
        mesa-vulkan-drivers
fi

# Generic WiFi firmware
log_step "Installing common WiFi firmware..."
apt_install \
    firmware-iwlwifi 2>/dev/null || true  # Intel WiFi

# NetworkManager for WiFi management
log_step "Ensuring NetworkManager is installed..."
apt_install network-manager

log_success "Generic drivers installed!"
log_info "If WiFi doesn't work, check 'lspci -k | grep -A3 Network' for your chipset."
