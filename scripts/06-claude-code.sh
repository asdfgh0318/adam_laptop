#!/bin/bash
# 06-claude-code.sh - Claude Code configuration
# Sets up hooks, permissions, and session logger

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "Configuring Claude Code"

REPO_DIR="$(get_repo_dir)"
DOTFILES="$(get_dotfiles_dir)"
CLAUDE_DIR="$HOME/.claude"
VIBECODING_DIR="$HOME/ŻYCIE/VIBECODING"

# Ensure directories exist
ensure_dir "$CLAUDE_DIR"
ensure_dir "$VIBECODING_DIR"

# Install session logger script
log_step "Installing session-logger.sh..."
if [ -f "$REPO_DIR/session-logger.sh" ]; then
    cp "$REPO_DIR/session-logger.sh" "$VIBECODING_DIR/session-logger.sh"
    chmod +x "$VIBECODING_DIR/session-logger.sh"
    log_success "session-logger.sh installed to $VIBECODING_DIR/"
else
    log_warn "session-logger.sh not found in repo"
fi

# Install Claude Code settings
log_step "Installing Claude Code settings..."
if [ -f "$DOTFILES/claude/settings.local.json" ]; then
    # Backup existing settings if present
    if [ -f "$CLAUDE_DIR/settings.local.json" ]; then
        backup_file "$CLAUDE_DIR/settings.local.json"
    fi

    cp "$DOTFILES/claude/settings.local.json" "$CLAUDE_DIR/settings.local.json"
    log_success "Claude Code settings installed"
else
    log_warn "No Claude Code settings found in dotfiles"
    log_info "Creating default settings with session logger hook..."

    # Create default settings with hook
    cat > "$CLAUDE_DIR/settings.local.json" << 'EOF'
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "Stop": [
      {
        "matcher": {},
        "hooks": [
          {
            "type": "command",
            "command": "/home/adam-koszalka/ŻYCIE/VIBECODING/session-logger.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
EOF
    log_success "Default Claude Code settings created with session logger hook"
fi

# Create WORK_LOGS file if it doesn't exist
WORK_LOGS="$VIBECODING_DIR/WORK_LOGS"
if [ ! -f "$WORK_LOGS" ]; then
    log_step "Creating WORK_LOGS file..."
    cat > "$WORK_LOGS" << 'EOF'
# Work Logs

Automated session logging by Claude Code.

EOF
    log_success "WORK_LOGS file created at $WORK_LOGS"
fi

log_success "Claude Code configuration complete!"
log_info "The Stop hook will log sessions to $WORK_LOGS"
