#!/bin/bash
# install.sh - Master installer for adam_laptop
# Sets up complete Sway desktop environment on Ubuntu

set -e
cd "$(dirname "$0")"
source scripts/common.sh

require_not_root

print_header "adam_laptop Setup - MacBook 10,1 / Ubuntu"

# Hardware detection
print_hardware_info

# Detect hardware type
if is_macbook; then
    HARDWARE="macbook"
else
    HARDWARE="generic"
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
