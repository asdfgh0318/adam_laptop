#!/bin/bash
# verify.sh - Post-install verification for adam_laptop
# Checks that all components installed correctly

source "$(dirname "$0")/scripts/common.sh"

PASS=0
FAIL=0
WARN=0

# Test functions
pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((FAIL++))
}

warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
    ((WARN++))
}

check_cmd() {
    if command -v "$1" &>/dev/null; then
        pass "$1 installed"
    else
        fail "$1 NOT found"
    fi
}

check_pkg() {
    if dpkg -l "$1" 2>/dev/null | grep -q "^ii"; then
        pass "$1 installed"
    else
        fail "$1 NOT installed"
    fi
}

check_file() {
    if [ -f "$1" ]; then
        pass "$1 exists"
    else
        fail "$1 MISSING"
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        pass "$1 exists"
    else
        fail "$1 MISSING"
    fi
}

check_service() {
    if systemctl is-enabled "$1" &>/dev/null; then
        pass "$1 service enabled"
    else
        fail "$1 service NOT enabled"
    fi
}

check_symlink() {
    if [ -L "$1" ] && [ -x "$1" ]; then
        pass "$(basename "$1") linked -> $(readlink -f "$1")"
    elif [ -L "$1" ]; then
        warn "$(basename "$1") linked but target missing: $(readlink "$1")"
    else
        fail "$(basename "$1") NOT linked at $1"
    fi
}

# ═══════════════════════════════════════════════
print_header "adam_laptop Post-Install Verification"
# ═══════════════════════════════════════════════

# ── Hardware Detection ──
print_header "Hardware Detection"
if is_macbook; then
    pass "Platform: MacBook (Apple)"
    HARDWARE="macbook"
elif is_thinkpad; then
    model=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
    pass "Platform: ThinkPad ($model)"
    HARDWARE="thinkpad"
else
    warn "Platform: Generic (not MacBook or ThinkPad)"
    HARDWARE="generic"
fi

if has_intel_graphics; then pass "Intel GPU detected"; fi
if has_intel_wifi; then pass "Intel WiFi detected"; fi
if has_broadcom_wifi; then pass "Broadcom WiFi detected"; fi
if has_fingerprint_reader; then pass "Fingerprint reader detected"; fi

# ── ŻYCIE Sync ──
print_header "ŻYCIE Files"
check_dir "$HOME/ŻYCIE"
check_dir "$HOME/ŻYCIE/.git"
if [ -d "$HOME/ŻYCIE/.git" ]; then
    remote=$(git -C "$HOME/ŻYCIE" remote get-url origin 2>/dev/null)
    if echo "$remote" | grep -q "zycie"; then
        pass "ŻYCIE git remote: $remote"
    else
        warn "ŻYCIE remote unexpected: $remote"
    fi
fi
check_dir "$HOME/ŻYCIE/VIBECODING"
check_dir "$HOME/ŻYCIE/PRACA"

# ── Base Packages (00-base.sh) ──
print_header "Base Packages"
for cmd in git curl wget htop btop neofetch tree jq; do
    check_cmd "$cmd"
done
check_cmd "rg"       # ripgrep
check_cmd "fdfind"   # fd-find
check_cmd "fzf"
check_cmd "cmake"
check_cmd "make"
check_cmd "iw"

# ── Sway & Wayland (01-sway.sh) ──
print_header "Sway & Wayland Stack"
check_cmd "sway"
check_cmd "swaylock"
check_cmd "swayidle"
check_cmd "wofi"
check_cmd "bemenu"
check_cmd "foot"
check_cmd "alacritty"
check_cmd "waybar"
check_cmd "wl-copy"
check_cmd "grim"
check_cmd "slurp"
check_cmd "brightnessctl"
check_cmd "acpi"
check_cmd "pavucontrol"
check_cmd "blueman-manager"

# PipeWire
if systemctl --user is-active pipewire &>/dev/null; then
    pass "PipeWire running"
elif pgrep -x pipewire &>/dev/null; then
    pass "PipeWire running (process found)"
else
    warn "PipeWire not running (normal if not in Sway session)"
fi

if systemctl --user is-active wireplumber &>/dev/null; then
    pass "WirePlumber running"
elif pgrep -x wireplumber &>/dev/null; then
    pass "WirePlumber running (process found)"
else
    warn "WirePlumber not running (normal if not in Sway session)"
fi

# Fonts
for font in "JetBrains Mono" "Ubuntu" "DejaVu Sans"; do
    if fc-list 2>/dev/null | grep -qi "$font"; then
        pass "Font: $font"
    else
        fail "Font MISSING: $font"
    fi
done

# ── Hardware Drivers ──
print_header "Hardware Drivers"

# Intel (common to all)
check_pkg "intel-microcode"
check_pkg "libgl1-mesa-dri"
check_pkg "mesa-vulkan-drivers"
check_pkg "intel-media-va-driver"
check_pkg "linux-firmware"

if [ "$HARDWARE" = "macbook" ]; then
    # MacBook-specific
    if has_broadcom_wifi; then
        check_pkg "bcmwl-kernel-source"
        check_file "/etc/modprobe.d/broadcom-sta-dkms.conf"
    fi
elif [ "$HARDWARE" = "thinkpad" ]; then
    # ThinkPad-specific
    check_pkg "thermald"
    check_service "thermald"
    check_pkg "tlp"
    check_service "tlp"
    check_pkg "bolt"
    check_service "bolt"

    # Battery thresholds
    if grep -q "START_CHARGE_THRESH_BAT0=75" /etc/tlp.conf 2>/dev/null; then
        pass "Battery start threshold: 75%"
    else
        warn "Battery start threshold not set in tlp.conf"
    fi
    if grep -q "STOP_CHARGE_THRESH_BAT0=80" /etc/tlp.conf 2>/dev/null; then
        pass "Battery stop threshold: 80%"
    else
        warn "Battery stop threshold not set in tlp.conf"
    fi

    # Fingerprint (optional)
    if has_fingerprint_reader; then
        check_pkg "fprintd"
        check_pkg "libpam-fprintd"
    fi

    # Keyboard backlight
    if [ -d /sys/class/leds/tpacpi::kbd_backlight ]; then
        pass "ThinkPad keyboard backlight device found"
    else
        warn "ThinkPad keyboard backlight device not found"
    fi

    # Thunderbolt
    if command -v boltctl &>/dev/null; then
        pass "boltctl available"
    else
        fail "boltctl NOT found"
    fi
fi

# ── VIBECODING Tools (04-tools.sh) ──
print_header "VIBECODING Tools"
check_dir "$HOME/bin"
check_symlink "$HOME/bin/bdmenu_ada"
check_symlink "$HOME/bin/settings"
check_symlink "$HOME/bin/settings-hub"
check_symlink "$HOME/bin/settings-dmenu"
check_symlink "$HOME/bin/settings-wofi"
check_file "$HOME/ŻYCIE/VIBECODING/session-logger.sh"

if echo "$PATH" | grep -q "$HOME/bin"; then
    pass "~/bin is in PATH"
else
    warn "~/bin is NOT in PATH - add to .bashrc: export PATH=\"\$HOME/bin:\$PATH\""
fi

# ── Doom Emacs (05-doom-emacs.sh) ──
print_header "Doom Emacs"
check_cmd "emacs"
check_dir "$HOME/.config/emacs"
check_dir "$HOME/.config/doom"
check_file "$HOME/.config/doom/init.el"
check_file "$HOME/.config/doom/config.el"
check_file "$HOME/.config/doom/packages.el"

if [ -x "$HOME/.config/emacs/bin/doom" ]; then
    pass "doom binary executable"
else
    fail "doom binary NOT found at ~/.config/emacs/bin/doom"
fi

for pkg in aspell sqlite3 pandoc shellcheck graphviz gnuplot; do
    check_cmd "$pkg"
done

# ── Claude Code (06-claude-code.sh) ──
print_header "Claude Code"
check_dir "$HOME/.claude"
check_file "$HOME/.claude/settings.local.json"

if [ -f "$HOME/.claude/settings.local.json" ]; then
    if grep -q "session-logger" "$HOME/.claude/settings.local.json" 2>/dev/null; then
        pass "Session logger hook configured"
    else
        warn "Session logger hook not found in settings"
    fi
fi

check_file "$HOME/ŻYCIE/VIBECODING/session-logger.sh"
if [ -x "$HOME/ŻYCIE/VIBECODING/session-logger.sh" ]; then
    pass "session-logger.sh is executable"
else
    warn "session-logger.sh not executable"
fi

# ── Dotfiles (restore-dotfiles.sh) ──
print_header "Dotfiles"

# Sway config
check_file "$HOME/.config/sway/config"
if [ -f "$HOME/.config/sway/config" ]; then
    if grep -q "XF86MonBrightnessDown" "$HOME/.config/sway/config"; then
        pass "Sway config has XF86 brightness keys"
    else
        warn "Sway config missing XF86 brightness keys"
    fi
    if grep -q "type:touchpad" "$HOME/.config/sway/config"; then
        pass "Sway config has touchpad configuration"
    else
        warn "Sway config missing touchpad configuration"
    fi
    if grep -q "type:pointer" "$HOME/.config/sway/config"; then
        pass "Sway config has TrackPoint configuration"
    else
        warn "Sway config missing TrackPoint configuration"
    fi
    if grep -q "XF86KbdBrightnessDown" "$HOME/.config/sway/config"; then
        pass "Sway config has keyboard backlight keys"
    else
        warn "Sway config missing keyboard backlight keys"
    fi
fi

check_file "$HOME/.config/sway/status.sh"
if [ -x "$HOME/.config/sway/status.sh" ]; then
    pass "status.sh is executable"
else
    fail "status.sh NOT executable"
fi

check_file "$HOME/.config/gtk-3.0/settings.ini"

# ── System State ──
print_header "System State"

# Battery
bat_path=""
for bp in /sys/class/power_supply/BAT0 /sys/class/power_supply/BAT1; do
    [ -d "$bp" ] && bat_path="$bp" && break
done
if [ -n "$bat_path" ]; then
    cap=$(cat "$bat_path/capacity" 2>/dev/null)
    status=$(cat "$bat_path/status" 2>/dev/null)
    pass "Battery: ${cap}% ($status) at $bat_path"
else
    warn "No battery found"
fi

# Display
if [ -d /sys/class/backlight/intel_backlight ]; then
    bright=$(cat /sys/class/backlight/intel_backlight/brightness 2>/dev/null)
    max=$(cat /sys/class/backlight/intel_backlight/max_brightness 2>/dev/null)
    pass "Display backlight: $bright/$max (intel_backlight)"
elif [ -d /sys/class/backlight/acpi_video0 ]; then
    pass "Display backlight: acpi_video0"
else
    warn "No backlight device found"
fi

# WiFi
wifi_dev=$(iw dev 2>/dev/null | awk '/Interface/{print $2}' | head -1)
if [ -n "$wifi_dev" ]; then
    ssid=$(iwgetid -r 2>/dev/null || echo "not connected")
    pass "WiFi interface: $wifi_dev (SSID: $ssid)"
else
    warn "No WiFi interface found"
fi

# Audio
if wpctl status &>/dev/null; then
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f%%", $2*100}')
    pass "Audio sink active (volume: $vol)"
else
    warn "wpctl not responding (normal if not in Sway session)"
fi

# Git repos
print_header "Git Repositories"
check_dir "$HOME/ŻYCIE/VIBECODING/adam_laptop/.git"
for repo in "$HOME/ŻYCIE/VIBECODING"/*/; do
    if [ -d "$repo/.git" ]; then
        name=$(basename "$repo")
        remote=$(git -C "$repo" remote get-url origin 2>/dev/null || echo "no remote")
        pass "$name -> $remote"
    fi
done

# ═══════════════════════════════════════════════
print_header "Results"
# ═══════════════════════════════════════════════

echo ""
echo -e "  ${GREEN}PASS: $PASS${NC}"
echo -e "  ${YELLOW}WARN: $WARN${NC}"
echo -e "  ${RED}FAIL: $FAIL${NC}"
echo ""

TOTAL=$((PASS + FAIL + WARN))
if [ "$FAIL" -eq 0 ]; then
    log_success "All $TOTAL checks passed! ($WARN warnings)"
    exit 0
elif [ "$FAIL" -le 3 ]; then
    log_warn "$FAIL failures out of $TOTAL checks. Review above."
    exit 1
else
    log_error "$FAIL failures out of $TOTAL checks. Installation may be incomplete."
    exit 2
fi
