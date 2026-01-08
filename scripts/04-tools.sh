#!/bin/bash
# 04-tools.sh - Install VIBECODING custom tools
# Sets up symlinks to custom tools in ~/bin

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Installing VIBECODING Tools"

VIBECODING_DIR="$HOME/ŻYCIE/VIBECODING"
BIN_DIR="$HOME/bin"

# Ensure ~/bin exists and is in PATH
ensure_dir "$BIN_DIR"

if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    log_warn "~/bin is not in PATH. Add this to your .bashrc:"
    log_info '  export PATH="$HOME/bin:$PATH"'
fi

# Function to create symlink
create_tool_link() {
    local source="$1"
    local name="$2"

    if [ -x "$source" ]; then
        ln -sf "$source" "$BIN_DIR/$name"
        log_success "Linked: $name -> $source"
    else
        log_warn "Not found or not executable: $source"
    fi
}

# bdmenu_ada - Application launcher
log_step "Setting up bdmenu_ada..."
create_tool_link "$VIBECODING_DIR/bdmenu_ada/bdmenu_ada" "bdmenu_ada"

# settings-tools - TUI settings suite
log_step "Setting up settings-tools..."
create_tool_link "$VIBECODING_DIR/settings-tools/settings" "settings"
create_tool_link "$VIBECODING_DIR/settings-tools/settings-hub" "settings-hub"
create_tool_link "$VIBECODING_DIR/settings-tools/settings-dmenu" "settings-dmenu"
create_tool_link "$VIBECODING_DIR/settings-tools/settings-wofi" "settings-wofi"

# session-logger for Claude Code hook
log_step "Setting up session-logger..."
REPO_DIR="$(get_repo_dir)"
if [ -f "$REPO_DIR/session-logger.sh" ]; then
    cp "$REPO_DIR/session-logger.sh" "$VIBECODING_DIR/session-logger.sh"
    chmod +x "$VIBECODING_DIR/session-logger.sh"
    log_success "Installed session-logger.sh to $VIBECODING_DIR/"
fi

log_success "VIBECODING tools installed!"
log_info "Tools available: bdmenu_ada, settings, settings-hub, settings-dmenu, settings-wofi"
