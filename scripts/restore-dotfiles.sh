#!/bin/bash
# restore-dotfiles.sh - Copy dotfiles FROM repo TO home directory
# Use this to apply backed up configs to a new/fresh system

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Restoring Dotfiles"

REPO_DIR="$(get_repo_dir)"
DOTFILES="$(get_dotfiles_dir)"

# Sway
log_step "Restoring Sway configuration..."
ensure_dir "$HOME/.config/sway"
if [ -f "$DOTFILES/config/sway/config" ]; then
    backup_file "$HOME/.config/sway/config"
    cp "$DOTFILES/config/sway/config" "$HOME/.config/sway/"
    log_success "Sway config restored"
fi
if [ -f "$DOTFILES/config/sway/status.sh" ]; then
    cp "$DOTFILES/config/sway/status.sh" "$HOME/.config/sway/"
    chmod +x "$HOME/.config/sway/status.sh"
    log_success "Sway status.sh restored"
fi

# Doom Emacs
log_step "Restoring Doom Emacs configuration..."
ensure_dir "$HOME/.config/doom"
if [ -d "$DOTFILES/config/doom" ]; then
    for file in "$DOTFILES/config/doom"/*.el "$DOTFILES/config/doom"/*.org; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            backup_file "$HOME/.config/doom/$filename"
            cp "$file" "$HOME/.config/doom/"
            log_success "Restored $filename"
        fi
    done
fi

# GTK settings
log_step "Restoring GTK settings..."
ensure_dir "$HOME/.config/gtk-3.0"
if [ -f "$DOTFILES/config/gtk-3.0/settings.ini" ]; then
    cp "$DOTFILES/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/"
    log_success "GTK settings restored"
fi

# Claude Code
log_step "Restoring Claude Code configuration..."
ensure_dir "$HOME/.claude"
if [ -f "$DOTFILES/claude/settings.local.json" ]; then
    backup_file "$HOME/.claude/settings.local.json"
    cp "$DOTFILES/claude/settings.local.json" "$HOME/.claude/"
    log_success "Claude Code settings restored"
fi

# Session logger
if [ -f "$REPO_DIR/session-logger.sh" ]; then
    ensure_dir "$HOME/ŻYCIE/VIBECODING"
    cp "$REPO_DIR/session-logger.sh" "$HOME/ŻYCIE/VIBECODING/"
    chmod +x "$HOME/ŻYCIE/VIBECODING/session-logger.sh"
    log_success "session-logger.sh restored"
fi

# Modprobe configs (requires sudo)
log_step "Restoring modprobe configuration..."
if [ -f "$DOTFILES/etc/modprobe.d/broadcom-sta-dkms.conf" ]; then
    log_info "Copying Broadcom WiFi blacklist (requires sudo)..."
    sudo cp "$DOTFILES/etc/modprobe.d/broadcom-sta-dkms.conf" /etc/modprobe.d/
    log_success "Broadcom blacklist config restored"
fi

log_success "All dotfiles restored!"
log_info "You may need to reload Sway (Mod+Shift+c) or log out to apply changes."
