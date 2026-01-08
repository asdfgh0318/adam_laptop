#!/bin/bash
# update.sh - Update and sync adam_laptop backup
# Core feature for keeping the setup current as it evolves

set -e
cd "$(dirname "$0")"
source scripts/common.sh

print_header "adam_laptop Update"

echo "What would you like to do?"
echo ""
echo "  1) Backup dotfiles    - Copy current configs to repo"
echo "  2) Sync tools         - Update submodules"
echo "  3) Full update        - Backup + commit + push"
echo "  4) Show diff          - Preview changes"
echo "  5) Pull updates       - Get latest from remote"
echo "  6) Apply configs      - Restore dotfiles to system"
echo ""
read -p "Choice [1-6]: " choice

case $choice in
    1)
        print_header "Backing Up Dotfiles"
        bash scripts/backup-dotfiles.sh
        log_info "Run 'git diff' to see changes"
        ;;
    2)
        print_header "Syncing Tools"
        bash scripts/sync-tools.sh
        ;;
    3)
        print_header "Full Update"

        log_step "Backing up dotfiles..."
        bash scripts/backup-dotfiles.sh

        log_step "Syncing tools..."
        bash scripts/sync-tools.sh

        log_step "Staging changes..."
        git add -A

        # Check if there are changes to commit
        if git diff --cached --quiet; then
            log_info "No changes to commit"
        else
            log_step "Creating commit..."
            TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
            git commit -m "Update: $TIMESTAMP

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"

            log_step "Pushing to remote..."
            if git remote | grep -q origin; then
                git push
                log_success "Changes pushed to remote!"
            else
                log_warn "No remote configured. Run:"
                log_info "  git remote add origin <url>"
                log_info "  git push -u origin main"
            fi
        fi
        ;;
    4)
        print_header "Changes Preview"
        git status
        echo ""
        git diff
        ;;
    5)
        print_header "Pulling Updates"

        if ! git remote | grep -q origin; then
            log_error "No remote configured!"
            log_info "Add a remote first:"
            log_info "  git remote add origin <url>"
            exit 1
        fi

        log_step "Fetching from remote..."
        git fetch origin

        log_step "Pulling changes..."
        git pull --rebase origin main

        log_step "Updating submodules..."
        git submodule update --init --recursive

        log_success "Pulled latest updates!"
        log_info "Run './install.sh' (option 4) to apply configs to system"
        ;;
    6)
        print_header "Applying Configs"
        bash scripts/restore-dotfiles.sh
        ;;
    *)
        log_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
log_success "Done!"
