#!/bin/bash
# Common functions for adam_laptop installer
# Source this file in other scripts: source "$(dirname "$0")/common.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}==>${NC} $1"
}

# Check if running as root (we don't want that)
require_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Don't run as root. Script will ask for sudo when needed."
        exit 1
    fi
}

# Check if a command exists
cmd_exists() {
    command -v "$1" &>/dev/null
}

# Install packages with apt (with logging)
apt_install() {
    local packages=("$@")
    log_info "Installing: ${packages[*]}"
    sudo apt install -y "${packages[@]}"
}

# Detect if running on MacBook hardware
is_macbook() {
    grep -qi "MacBook\|Apple" /sys/class/dmi/id/product_name 2>/dev/null || \
    grep -qi "MacBook\|Apple" /sys/class/dmi/id/sys_vendor 2>/dev/null
}

# Detect if running on ThinkPad hardware
is_thinkpad() {
    grep -qi "ThinkPad" /sys/class/dmi/id/product_name 2>/dev/null
}

# Detect ThinkPad T480s specifically
is_thinkpad_t480s() {
    grep -qi "T480s" /sys/class/dmi/id/product_name 2>/dev/null
}

# Detect Intel WiFi chipset
has_intel_wifi() {
    lspci 2>/dev/null | grep -qi "Intel.*Wireless\|Intel.*Wi-Fi\|Intel.*WiFi"
}

# Detect fingerprint reader
has_fingerprint_reader() {
    lsusb 2>/dev/null | grep -qi "Fingerprint\|Validity\|06cb:"
}

# Detect Broadcom WiFi chipset
has_broadcom_wifi() {
    lspci 2>/dev/null | grep -qi "BCM43"
}

# Detect Intel graphics
has_intel_graphics() {
    lspci 2>/dev/null | grep -qi "Intel.*Graphics"
}

# Detect NVIDIA graphics
has_nvidia_graphics() {
    lspci 2>/dev/null | grep -qi "NVIDIA"
}

# Detect AMD graphics
has_amd_graphics() {
    lspci 2>/dev/null | grep -qi "AMD.*VGA\|ATI.*VGA"
}

# Get the repo directory (parent of scripts/)
get_repo_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

# Get the dotfiles directory
get_dotfiles_dir() {
    echo "$(get_repo_dir)/dotfiles"
}

# Backup a file before overwriting
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        log_info "Backed up $file to $backup"
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_info "Created directory: $dir"
    fi
}

# Print a header
print_header() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Print hardware info
print_hardware_info() {
    print_header "Hardware Detection"

    if is_macbook; then
        log_success "Platform: MacBook (Apple)"
    elif is_thinkpad; then
        local model
        model=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
        log_success "Platform: Lenovo ThinkPad ($model)"
    else
        log_info "Platform: Generic PC"
    fi

    if has_broadcom_wifi; then
        log_info "WiFi: Broadcom (will use wl driver)"
    fi

    if has_intel_wifi; then
        log_info "WiFi: Intel (iwlwifi - works with linux-firmware)"
    fi

    if has_fingerprint_reader; then
        log_info "Fingerprint: Reader detected (fprintd available)"
    fi

    if has_intel_graphics; then
        log_info "GPU: Intel (i915 driver)"
    fi

    if has_nvidia_graphics; then
        log_warn "GPU: NVIDIA detected (manual driver install recommended)"
    fi

    if has_amd_graphics; then
        log_info "GPU: AMD (mesa driver)"
    fi

    echo ""
}
