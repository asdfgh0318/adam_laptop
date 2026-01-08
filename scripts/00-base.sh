#!/bin/bash
# 00-base.sh - Install base system packages
# These are essential tools needed for development and system management

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing Base System Packages"

log_step "Updating package lists..."
sudo apt update

log_step "Installing essential tools..."
apt_install \
    git \
    curl \
    wget \
    htop \
    btop \
    neofetch \
    tree \
    unzip \
    zip \
    jq

log_step "Installing search tools..."
apt_install \
    ripgrep \
    fd-find \
    fzf

log_step "Installing build tools..."
apt_install \
    build-essential \
    cmake \
    pkg-config

log_step "Installing networking tools..."
apt_install \
    net-tools \
    wireless-tools \
    iw

log_success "Base packages installed successfully!"
