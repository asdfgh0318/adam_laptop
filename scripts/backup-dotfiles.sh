#!/bin/bash
# backup-dotfiles.sh - Copy dotfiles FROM home directory TO repo
# Use this to capture current system state before committing

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Backing Up Dotfiles"

REPO_DIR="$(get_repo_dir)"
DOTFILES="$(get_dotfiles_dir)"

# Sway
log_step "Backing up Sway configuration..."
ensure_dir "$DOTFILES/config/sway"
if [ -f "$HOME/.config/sway/config" ]; then
    cp "$HOME/.config/sway/config" "$DOTFILES/config/sway/"
    log_success "Sway config backed up"
fi
if [ -f "$HOME/.config/sway/status.sh" ]; then
    cp "$HOME/.config/sway/status.sh" "$DOTFILES/config/sway/"
    log_success "Sway status.sh backed up"
fi

# Doom Emacs
log_step "Backing up Doom Emacs configuration..."
ensure_dir "$DOTFILES/config/doom"
if [ -d "$HOME/.config/doom" ]; then
    for file in init.el config.el packages.el; do
        if [ -f "$HOME/.config/doom/$file" ]; then
            cp "$HOME/.config/doom/$file" "$DOTFILES/config/doom/"
            log_success "Backed up $file"
        fi
    done
    # Also backup cheatsheet if exists
    if [ -f "$HOME/.config/doom/doom-cheatsheet.org" ]; then
        cp "$HOME/.config/doom/doom-cheatsheet.org" "$DOTFILES/config/doom/"
        log_success "Backed up doom-cheatsheet.org"
    fi
fi

# GTK settings
log_step "Backing up GTK settings..."
ensure_dir "$DOTFILES/config/gtk-3.0"
if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
    cp "$HOME/.config/gtk-3.0/settings.ini" "$DOTFILES/config/gtk-3.0/"
    log_success "GTK settings backed up"
fi

# Claude Code
log_step "Backing up Claude Code configuration..."
ensure_dir "$DOTFILES/claude"
if [ -f "$HOME/.claude/settings.local.json" ]; then
    cp "$HOME/.claude/settings.local.json" "$DOTFILES/claude/"
    log_success "Claude Code settings backed up"
fi

# Session logger
if [ -f "$HOME/ŻYCIE/VIBECODING/session-logger.sh" ]; then
    cp "$HOME/ŻYCIE/VIBECODING/session-logger.sh" "$REPO_DIR/"
    log_success "session-logger.sh backed up"
fi

# Modprobe configs (read with sudo if needed)
log_step "Backing up modprobe configuration..."
ensure_dir "$DOTFILES/etc/modprobe.d"
if [ -f "/etc/modprobe.d/broadcom-sta-dkms.conf" ]; then
    # Try without sudo first
    if cp "/etc/modprobe.d/broadcom-sta-dkms.conf" "$DOTFILES/etc/modprobe.d/" 2>/dev/null; then
        log_success "Broadcom blacklist config backed up"
    else
        log_info "Copying Broadcom config (requires sudo)..."
        sudo cp "/etc/modprobe.d/broadcom-sta-dkms.conf" "$DOTFILES/etc/modprobe.d/"
        sudo chown "$USER:$USER" "$DOTFILES/etc/modprobe.d/broadcom-sta-dkms.conf"
        log_success "Broadcom blacklist config backed up"
    fi
fi

# Package list snapshots
log_step "Creating package list snapshots..."
dpkg --get-selections > "$REPO_DIR/package-list.txt"
log_success "Full package list saved to package-list.txt"

apt list --installed 2>/dev/null | grep -E 'sway|waybar|wofi|bemenu|foot|pipewire|emacs|doom' > "$REPO_DIR/key-packages.txt" || true
log_success "Key packages saved to key-packages.txt"

log_success "All dotfiles backed up!"
log_info "Run 'git diff' to see changes, then commit with git."
