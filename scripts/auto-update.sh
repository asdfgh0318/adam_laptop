#!/bin/bash
# auto-update.sh - Automated daily backup to GitHub
# Run via cron: 0 20 * * * /home/adam-koszalka/ŻYCIE/VIBECODING/adam_laptop/scripts/auto-update.sh

set -e

REPO_DIR="/home/adam-koszalka/ŻYCIE/VIBECODING/adam_laptop"
LOG_FILE="$REPO_DIR/auto-update.log"

# Log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

cd "$REPO_DIR"

log "Starting auto-update..."

# Backup dotfiles
log "Backing up dotfiles..."
bash scripts/backup-dotfiles.sh >> "$LOG_FILE" 2>&1

# Check if there are changes
if git diff --quiet && git diff --cached --quiet; then
    log "No changes to commit"
    exit 0
fi

# Stage all changes
git add -A

# Commit with timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
git commit -m "Auto-update: $TIMESTAMP

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>" >> "$LOG_FILE" 2>&1

# Push to remote
if git push >> "$LOG_FILE" 2>&1; then
    log "Successfully pushed to GitHub"
else
    log "ERROR: Failed to push to GitHub"
    exit 1
fi

log "Auto-update complete"

# Keep log file manageable (last 1000 lines)
tail -n 1000 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
