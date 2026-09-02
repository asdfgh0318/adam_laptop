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

# foot terminal colours
ensure_dir "$DOTFILES/config/foot"
[ -f "$HOME/.config/foot/foot.ini" ] && cp "$HOME/.config/foot/foot.ini" "$DOTFILES/config/foot/" && log_success "foot.ini backed up"

# bashrc additions (everything after Ubuntu's stock block), /home/<user> -> $HOME
if grep -q 'if ! shopt -oq posix' "$HOME/.bashrc"; then
    start=$(grep -n 'if ! shopt -oq posix' "$HOME/.bashrc" | cut -d: -f1)
    end=$(awk -v s="$start" 'NR>s && /^fi$/ {print NR; exit}' "$HOME/.bashrc")
    { echo "# ---- bashrc additions (captured by backup-dotfiles.sh) ----"
      sed -n "$((end+1)),\$p" "$HOME/.bashrc" | sed "s|$HOME/|\$HOME/|g"; } > "$DOTFILES/bashrc-additions.sh"
    log_success "bashrc additions backed up"
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

# Modprobe configs (read with sudo if needed) - MacBook only
log_step "Backing up modprobe configuration..."
if is_macbook; then
    ensure_dir "$DOTFILES/etc/modprobe.d"
    if [ -f "/etc/modprobe.d/broadcom-sta-dkms.conf" ]; then
        if cp "/etc/modprobe.d/broadcom-sta-dkms.conf" "$DOTFILES/etc/modprobe.d/" 2>/dev/null; then
            log_success "Broadcom blacklist config backed up"
        else
            log_info "Copying Broadcom config (requires sudo)..."
            sudo cp "/etc/modprobe.d/broadcom-sta-dkms.conf" "$DOTFILES/etc/modprobe.d/"
            sudo chown "$USER:$USER" "$DOTFILES/etc/modprobe.d/broadcom-sta-dkms.conf"
            log_success "Broadcom blacklist config backed up"
        fi
    fi
else
    log_info "Non-MacBook hardware - skipping Broadcom modprobe backup"
fi

# Package list snapshots
log_step "Creating package list snapshots..."
dpkg --get-selections > "$REPO_DIR/package-list.txt"
log_success "Full package list saved to package-list.txt"

# Manifests that setup-pocket3.sh actually installs from
ensure_dir "$REPO_DIR/manifests"
apt-mark showmanual | sort -u | grep -vxF -f "$REPO_DIR/manifests/apt-exclude.txt" > "$REPO_DIR/manifests/apt-packages.txt" 2>/dev/null || apt-mark showmanual | sort -u > "$REPO_DIR/manifests/apt-packages.txt"
snap list 2>/dev/null | tail -n +2 | awk '{print $1}' | grep -vxF -f "$REPO_DIR/manifests/snap-exclude.txt" > "$REPO_DIR/manifests/snaps.txt" 2>/dev/null || true
snap list 2>/dev/null | tail -n +2 | awk '$6 ~ /classic/ {print $1}' > "$REPO_DIR/manifests/snaps-classic.txt"
flatpak list --app --columns=application 2>/dev/null > "$REPO_DIR/manifests/flatpaks.txt" || true
pip3 list --user --format=freeze 2>/dev/null > "$REPO_DIR/manifests/pip-user.txt" || true
log_success "manifests/ regenerated ($(wc -l < "$REPO_DIR/manifests/apt-packages.txt") apt, $(wc -l < "$REPO_DIR/manifests/snaps.txt") snaps)"

apt list --installed 2>/dev/null | grep -E 'sway|waybar|wofi|bemenu|foot|pipewire|emacs|doom' > "$REPO_DIR/key-packages.txt" || true
log_success "Key packages saved to key-packages.txt"

log_success "All dotfiles backed up!"
log_info "Run 'git diff' to see changes, then commit with git."
