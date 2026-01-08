#!/bin/bash
# 01-sway.sh - Install Sway window manager and Wayland tools
# Sets up a complete Wayland desktop environment

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing Sway Window Manager & Wayland Stack"

log_step "Installing Sway and core components..."
apt_install \
    sway \
    swaybg \
    swaylock \
    swayidle \
    sway-backgrounds

log_step "Installing application launchers..."
apt_install \
    wofi \
    bemenu

log_step "Installing terminal emulators..."
apt_install \
    foot \
    alacritty

log_step "Installing status bar..."
apt_install \
    waybar

log_step "Installing Wayland utilities..."
apt_install \
    wl-clipboard \
    grim \
    slurp \
    mako-notifier \
    wdisplays

log_step "Installing audio stack (PipeWire)..."
apt_install \
    pipewire \
    pipewire-pulse \
    pipewire-audio \
    wireplumber \
    pavucontrol

log_step "Installing brightness and power tools..."
apt_install \
    brightnessctl \
    acpi

log_step "Installing Bluetooth tools..."
apt_install \
    bluez \
    blueman

log_step "Installing XWayland for X11 app compatibility..."
apt_install \
    xwayland

log_step "Installing fonts..."
apt_install \
    fonts-jetbrains-mono \
    fonts-ubuntu \
    fonts-dejavu

log_success "Sway and Wayland stack installed!"
log_info "Run 'sway' from a TTY to start the desktop environment."
