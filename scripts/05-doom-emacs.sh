#!/bin/bash
# 05-doom-emacs.sh - Full Doom Emacs installation
# Installs Emacs, Doom framework, and your custom config

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing Doom Emacs"

REPO_DIR="$(get_repo_dir)"
DOTFILES="$(get_dotfiles_dir)"

# Step 1: Install Emacs and dependencies
log_step "[1/6] Installing Emacs and dependencies..."
apt_install \
    emacs \
    git \
    ripgrep \
    fd-find

log_step "[2/6] Installing build tools for Doom..."
apt_install \
    build-essential \
    cmake \
    libtool \
    libtool-bin

log_step "[3/6] Installing recommended tools..."
apt_install \
    aspell \
    aspell-en \
    sqlite3 \
    libsqlite3-dev \
    pandoc \
    shellcheck \
    graphviz \
    gnuplot \
    imagemagick \
    libvterm-dev \
    libjansson-dev

log_step "[4/6] Installing fonts..."
apt_install \
    fonts-firacode \
    fonts-hack \
    fonts-dejavu

# Step 2: Backup existing Emacs config
if [ -d "$HOME/.config/emacs" ]; then
    log_warn "Existing ~/.config/emacs found - backing up..."
    mv "$HOME/.config/emacs" "$HOME/.config/emacs.bak.$(date +%Y%m%d_%H%M%S)"
fi

if [ -d "$HOME/.emacs.d" ]; then
    log_warn "Existing ~/.emacs.d found - backing up..."
    mv "$HOME/.emacs.d" "$HOME/.emacs.d.bak.$(date +%Y%m%d_%H%M%S)"
fi

# Step 3: Clone Doom Emacs
log_step "[5/6] Cloning Doom Emacs..."
if [ ! -d "$HOME/.config/emacs" ]; then
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    log_success "Doom Emacs cloned to ~/.config/emacs"
else
    log_info "Doom Emacs already exists at ~/.config/emacs"
fi

# Step 4: Install Doom config files
log_step "[6/6] Installing Doom config files..."
ensure_dir "$HOME/.config/doom"

if [ -d "$DOTFILES/config/doom" ]; then
    cp -r "$DOTFILES/config/doom/"* "$HOME/.config/doom/"
    log_success "Doom config files installed"
else
    log_warn "No Doom config found in dotfiles - using defaults"
fi

# Step 5: Add Doom to PATH hint
log_info ""
log_info "Add Doom to your PATH by adding this to ~/.bashrc:"
log_info '  export PATH="$HOME/.config/emacs/bin:$PATH"'
log_info ""

# Step 6: Run Doom install
log_step "Running Doom installer..."
log_warn "This may take several minutes..."

if [ -x "$HOME/.config/emacs/bin/doom" ]; then
    "$HOME/.config/emacs/bin/doom" install --no-config
    "$HOME/.config/emacs/bin/doom" sync
    log_success "Doom Emacs installed and synced!"
else
    log_error "Doom binary not found. Run manually:"
    log_info "  ~/.config/emacs/bin/doom install"
fi

log_success "Doom Emacs setup complete!"
