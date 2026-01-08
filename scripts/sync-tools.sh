#!/bin/bash
# sync-tools.sh - Sync VIBECODING tool submodules
# Updates all git submodules to their latest versions

set -e
source "$(dirname "$0")/common.sh"

print_header "Syncing VIBECODING Tools"

REPO_DIR="$(get_repo_dir)"
cd "$REPO_DIR"

# Check if we have submodules
if [ -f ".gitmodules" ]; then
    log_step "Updating git submodules..."
    git submodule update --init --recursive
    git submodule update --remote --merge
    log_success "Submodules updated to latest"
else
    log_info "No git submodules configured."
    log_info "Tools are linked via symlinks to ~/ŻYCIE/VIBECODING/"
fi

# Verify tool links
log_step "Verifying tool installations..."
VIBECODING_DIR="$HOME/ŻYCIE/VIBECODING"
BIN_DIR="$HOME/bin"

check_tool() {
    local name="$1"
    if [ -x "$BIN_DIR/$name" ]; then
        log_success "$name is linked"
    else
        log_warn "$name not found in ~/bin"
    fi
}

check_tool "bdmenu_ada"
check_tool "settings"
check_tool "settings-hub"
check_tool "settings-dmenu"

log_success "Tool sync complete!"
