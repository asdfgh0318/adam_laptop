#!/bin/bash
# 02-drivers-pocket3.sh - GPD Pocket 3 hardware quirks
# Portrait panel rotation, touch/stylus matrix, accelerometer, audio, suspend.
# Values from wimpysworld/umpc-ubuntu (the Ubuntu MATE Pocket 3 reference).
# The full story is in docs/GPD-POCKET3.md; this is the same as setup-pocket3.sh phase 7.

set -e
source "$(dirname "$0")/common.sh"
require_not_root

print_header "GPD Pocket 3 hardware quirks"
if ! is_gpd_pocket3; then
    log_warn "Not a GPD Pocket 3 - skipping."; exit 0
fi
REPO_DIR="$(get_repo_dir)"
export PAYLOAD="$REPO_DIR"
bash "$REPO_DIR/setup-pocket3.sh" 0 7
