#!/bin/bash
# sync-check.sh - Compare repo sync status between local machine and a remote
# Usage: ./scripts/sync-check.sh [user@host]
# If no host given, defaults to adam@10.77.96.106 (ThinkPad T480s)

set -e
source "$(dirname "$0")/common.sh"

REMOTE="${1:-adam@10.77.96.106}"
ZYCIE_DIR="$HOME/ŻYCIE"

# Repos to check: directory_name relative to ~/ŻYCIE
VIBECODING_REPOS=(
    "VIBECODING/adam_laptop"
    "VIBECODING/ars_noise_measurement"
    "VIBECODING/bangle"
    "VIBECODING/bdmenu_ada"
    "VIBECODING/doom_emacs_setup"
    "VIBECODING/settings-tools"
    "VIBECODING/space-station"
    "VIBECODING/stasia-woda"
    "VIBECODING/symulator_fpv"
    "VIBECODING/vibecoding-logger"
)

PRACA_REPOS=(
    "PRACA/aruco_drone_nav"
    "PRACA/BRIK_PDB"
    "PRACA/brik_fail_analysis"
)

# Check SSH connectivity
check_remote() {
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$REMOTE" "echo ok" &>/dev/null; then
        log_error "Cannot reach $REMOTE via SSH"
        log_info "Make sure the remote machine is on and SSH is accessible"
        exit 1
    fi
}

# Get local repo info: commit hash, branch, dirty status, unpushed count
get_local_info() {
    local repo_path="$ZYCIE_DIR/$1"
    if [ ! -d "$repo_path/.git" ]; then
        echo "MISSING|||||"
        return
    fi
    cd "$repo_path"
    local commit branch dirty unpushed
    commit=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "?")
    dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    unpushed=$(git log --oneline @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    echo "${commit}|${branch}|${dirty}|${unpushed}"
}

# Get remote repo info via SSH
get_remote_info() {
    local repo_rel="$1"
    ssh -o ConnectTimeout=5 "$REMOTE" "
        repo_path=\"\$HOME/ŻYCIE/$repo_rel\"
        if [ ! -d \"\$repo_path/.git\" ]; then
            echo 'MISSING||||'
            exit 0
        fi
        cd \"\$repo_path\"
        commit=\$(git rev-parse --short HEAD 2>/dev/null || echo 'none')
        branch=\$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')
        dirty=\$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        unpushed=\$(git log --oneline @{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
        echo \"\${commit}|\${branch}|\${dirty}|\${unpushed}\"
    " 2>/dev/null
}

# Format a status cell
format_status() {
    local commit="$1" branch="$2" dirty="$3" unpushed="$4"
    if [ "$commit" = "MISSING" ]; then
        echo "MISSING"
        return
    fi
    local status="${commit} (${branch})"
    [ "$dirty" -gt 0 ] 2>/dev/null && status="$status +${dirty}dirty"
    [ "$unpushed" -gt 0 ] 2>/dev/null && status="$status +${unpushed}unpushed"
    echo "$status"
}

# Compare and print
compare_repo() {
    local repo_rel="$1"
    local repo_name
    repo_name=$(basename "$repo_rel")

    local local_info remote_info
    local_info=$(get_local_info "$repo_rel")
    remote_info=$(get_remote_info "$repo_rel")

    IFS='|' read -r l_commit l_branch l_dirty l_unpushed <<< "$local_info"
    IFS='|' read -r r_commit r_branch r_dirty r_unpushed <<< "$remote_info"

    local l_status r_status sync_icon
    l_status=$(format_status "$l_commit" "$l_branch" "$l_dirty" "$l_unpushed")
    r_status=$(format_status "$r_commit" "$r_branch" "$r_dirty" "$r_unpushed")

    if [ "$l_commit" = "MISSING" ] || [ "$r_commit" = "MISSING" ]; then
        sync_icon="${RED}MISSING${NC}"
    elif [ "$l_commit" = "$r_commit" ] && [ "${l_dirty:-0}" -eq 0 ] && [ "${r_dirty:-0}" -eq 0 ] && [ "${l_unpushed:-0}" -eq 0 ] && [ "${r_unpushed:-0}" -eq 0 ]; then
        sync_icon="${GREEN}SYNCED${NC}"
        SYNCED_COUNT=$((SYNCED_COUNT + 1))
    elif [ "$l_commit" = "$r_commit" ]; then
        sync_icon="${YELLOW}DIRTY${NC}"
    else
        sync_icon="${RED}DIFFER${NC}"
    fi

    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    printf "  %-25s %-30s %-30s %b\n" "$repo_name" "$l_status" "$r_status" "$sync_icon"
}

# --- Main ---

LOCAL_HOST=$(hostname 2>/dev/null || echo "local")
REMOTE_HOST=$(ssh -o ConnectTimeout=5 "$REMOTE" "hostname" 2>/dev/null || echo "$REMOTE")

print_header "Repo Sync Check: $LOCAL_HOST <-> $REMOTE_HOST"

log_step "Checking SSH connectivity to $REMOTE..."
check_remote
log_success "Connected to $REMOTE"
echo ""

SYNCED_COUNT=0
TOTAL_COUNT=0

# Print table header
printf "  ${CYAN}%-25s %-30s %-30s %s${NC}\n" "REPO" "$LOCAL_HOST" "$REMOTE_HOST" "STATUS"
echo "  ────────────────────────────────────────────────────────────────────────────────────────────────"

echo ""
echo -e "  ${BLUE}VIBECODING${NC}"
for repo in "${VIBECODING_REPOS[@]}"; do
    compare_repo "$repo"
done

echo ""
echo -e "  ${BLUE}PRACA${NC}"
for repo in "${PRACA_REPOS[@]}"; do
    compare_repo "$repo"
done

echo ""
echo "  ────────────────────────────────────────────────────────────────────────────────────────────────"

if [ "$SYNCED_COUNT" -eq "$TOTAL_COUNT" ]; then
    log_success "All $TOTAL_COUNT repos are in sync!"
else
    OUT_OF_SYNC=$((TOTAL_COUNT - SYNCED_COUNT))
    log_warn "$SYNCED_COUNT/$TOTAL_COUNT synced, $OUT_OF_SYNC need attention"
    echo ""
    log_info "To fix out-of-sync repos:"
    log_info "  1. Commit and push local changes:  git add -A && git commit && git push"
    log_info "  2. Pull on the other machine:      git pull"
fi

echo ""
