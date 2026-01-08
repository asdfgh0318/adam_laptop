#!/bin/bash

# Auto-logs Claude sessions (backup logger)
# Triggered by Claude Code Stop hook

WORK_LOGS="/home/adam-koszalka/ŻYCIE/VIBECODING/WORK_LOGS"
TIME=$(date +%H:%M)

# Read JSON from stdin, extract working directory
INPUT=$(cat)
DIR=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]+' 2>/dev/null | xargs basename 2>/dev/null || echo "unknown")

# Append session marker
echo "- **$TIME** [session] worked in $DIR" >> "$WORK_LOGS"
