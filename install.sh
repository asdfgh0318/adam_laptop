#!/bin/bash
# install.sh - Master installer for adam_laptop
# Sets up complete Sway desktop environment on Ubuntu

set -e
cd "$(dirname "$0")"
source scripts/common.sh

require_not_root

print_header "adam_laptop Setup - Multi-Hardware Ubuntu + Sway"

# Hardware detection
print_hardware_info

# Detect hardware type
if is_macbook; then
    HARDWARE="macbook"
elif is_thinkpad; then
    HARDWARE="thinkpad"
else
    HARDWARE="generic"
fi

# Sync ŻYCIE personal files from GitHub (private repo)
ZYCIE_REPO="https://github.com/asdfgh0318/zycie.git"
ZYCIE_DIR="$HOME/ŻYCIE"

print_header "ŻYCIE Sync"
if [ ! -d "$ZYCIE_DIR" ]; then
    # No ŻYCIE directory - clone from GitHub
    log_step "Cloning ŻYCIE from GitHub..."
    if cmd_exists gh; then
        gh repo clone asdfgh0318/zycie "$ZYCIE_DIR"
    else
        git clone "$ZYCIE_REPO" "$ZYCIE_DIR"
    fi
    log_success "ŻYCIE cloned to $ZYCIE_DIR"
elif [ ! -d "$ZYCIE_DIR/.git" ]; then
    # ŻYCIE exists but is not a git repo - init and merge with remote
    log_step "ŻYCIE exists but is not a git repo. Merging with GitHub..."
    cd "$ZYCIE_DIR"
    git init
    git branch -m main
    git add .
    git commit -m "Local ŻYCIE snapshot before merge" || true
    git remote add origin "$ZYCIE_REPO"
    git fetch origin
    git merge origin/main --allow-unrelated-histories --no-edit || {
        log_warn "Merge conflicts detected. Keeping local versions of conflicting files."
        git checkout --ours . 2>/dev/null || true
        git add .
        git commit -m "Merged with GitHub (local files preferred)" || true
    }
    git push -u origin main || log_warn "Push failed - authenticate with 'gh auth login' and retry"
    cd "$(dirname "$0")"
    log_success "ŻYCIE merged and synced"
else
    # ŻYCIE is already a git repo - pull latest and push local changes
    log_step "Syncing ŻYCIE with GitHub..."
    cd "$ZYCIE_DIR"
    git add . 2>/dev/null
    git commit -m "Auto-sync: local changes before pull" 2>/dev/null || true
    git pull --no-edit origin main 2>/dev/null || {
        log_warn "Pull had conflicts. Keeping local versions."
        git checkout --ours . 2>/dev/null || true
        git add .
        git commit -m "Resolved conflicts (local preferred)" || true
    }
    git push origin main 2>/dev/null || log_warn "Push failed - check GitHub auth"
    cd "$(dirname "$0")"
    log_success "ŻYCIE synced with GitHub"
fi

# Installation menu
echo "Select installation type:"
echo ""
echo "  1) Full install     - Everything (base + sway + drivers + tools + doom + claude)"
echo "  2) Desktop only     - Base + Sway + drivers (no Doom/Claude)"
echo "  3) Minimal          - Base + Sway only"
echo "  4) Dotfiles only    - Just restore config files"
echo "  5) Custom           - Choose components"
echo ""
read -p "Choice [1-5]: " install_type

case $install_type in
    1)
        print_header "Full Installation"
        bash scripts/00-base.sh
        bash scripts/01-sway.sh
        if [ "$HARDWARE" = "macbook" ]; then
            bash scripts/02-drivers-macbook.sh
        elif [ "$HARDWARE" = "thinkpad" ]; then
            bash scripts/02-drivers-t480s.sh
        else
            bash scripts/03-drivers-generic.sh
        fi
        bash scripts/04-tools.sh
        bash scripts/05-doom-emacs.sh
        bash scripts/06-claude-code.sh
        bash scripts/restore-dotfiles.sh
        ;;
    2)
        print_header "Desktop Installation"
        bash scripts/00-base.sh
        bash scripts/01-sway.sh
        if [ "$HARDWARE" = "macbook" ]; then
            bash scripts/02-drivers-macbook.sh
        elif [ "$HARDWARE" = "thinkpad" ]; then
            bash scripts/02-drivers-t480s.sh
        else
            bash scripts/03-drivers-generic.sh
        fi
        bash scripts/04-tools.sh
        bash scripts/restore-dotfiles.sh
        ;;
    3)
        print_header "Minimal Installation"
        bash scripts/00-base.sh
        bash scripts/01-sway.sh
        bash scripts/restore-dotfiles.sh
        ;;
    4)
        print_header "Restoring Dotfiles"
        bash scripts/restore-dotfiles.sh
        ;;
    5)
        print_header "Custom Installation"
        echo "Select components to install:"
        echo ""

        read -p "Install base packages? [Y/n]: " do_base
        read -p "Install Sway desktop? [Y/n]: " do_sway
        read -p "Install hardware drivers? [Y/n]: " do_drivers
        read -p "Install VIBECODING tools? [Y/n]: " do_tools
        read -p "Install Doom Emacs? [Y/n]: " do_doom
        read -p "Install Claude Code config? [Y/n]: " do_claude
        read -p "Restore dotfiles? [Y/n]: " do_dotfiles

        [[ ! "$do_base" =~ ^[Nn] ]] && bash scripts/00-base.sh
        [[ ! "$do_sway" =~ ^[Nn] ]] && bash scripts/01-sway.sh

        if [[ ! "$do_drivers" =~ ^[Nn] ]]; then
            if [ "$HARDWARE" = "macbook" ]; then
                bash scripts/02-drivers-macbook.sh
            elif [ "$HARDWARE" = "thinkpad" ]; then
                bash scripts/02-drivers-t480s.sh
            else
                bash scripts/03-drivers-generic.sh
            fi
        fi

        [[ ! "$do_tools" =~ ^[Nn] ]] && bash scripts/04-tools.sh
        [[ ! "$do_doom" =~ ^[Nn] ]] && bash scripts/05-doom-emacs.sh
        [[ ! "$do_claude" =~ ^[Nn] ]] && bash scripts/06-claude-code.sh
        [[ ! "$do_dotfiles" =~ ^[Nn] ]] && bash scripts/restore-dotfiles.sh
        ;;
    *)
        log_error "Invalid choice"
        exit 1
        ;;
esac

print_header "Installation Complete!"

log_success "Setup finished successfully!"
echo ""
log_info "Next steps:"
log_info "  1. Log out and start Sway from TTY: sway"
log_info "  2. Or reboot if drivers were installed"
echo ""
log_info "Key bindings:"
log_info "  Mod+Return    - Terminal"
log_info "  Mod+d         - Wofi launcher"
log_info "  Mod+Shift+s   - bdmenu_ada launcher"
log_info "  Mod+Shift+e   - Exit Sway"
echo ""
log_warn "If WiFi doesn't work, reboot first!"

if [ "$HARDWARE" = "thinkpad" ]; then
    echo ""
    log_info "ThinkPad-specific tips:"
    log_info "  - Run 'fprintd-enroll' to set up fingerprint login"
    log_info "  - TLP is managing power - check with: sudo tlp-stat -b"
    log_info "  - Battery thresholds set to 75%-80% for longevity"
    log_info "  - Authorize Thunderbolt devices with: boltctl"
fi
