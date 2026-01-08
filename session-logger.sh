#!/bin/bash

# Claude Code Session Logger
# Logs session activity to WORK_LOGS when conversation ends
# Receives JSON input from Claude Code Stop hook

WORK_LOGS="/home/adam-koszalka/ŻYCIE/VIBECODING/WORK_LOGS"
TODAY=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)

# Read JSON input from stdin
INPUT=$(cat)

# Extract working directory from input
WORK_DIR=$(echo "$INPUT" | grep -oP '"cwd"\s*:\s*"\K[^"]+' 2>/dev/null || echo "unknown")

# Extract stop reason
STOP_REASON=$(echo "$INPUT" | grep -oP '"stop_reason"\s*:\s*"\K[^"]+' 2>/dev/null || echo "end_turn")

# Get the transcript summary if available (from tool_results or conversation)
TRANSCRIPT=$(echo "$INPUT" | grep -oP '"transcript"\s*:\s*\[\K[^\]]+' 2>/dev/null | head -c 500)

# Check if today's entry exists, if not create header
if ! grep -q "^## $TODAY" "$WORK_LOGS" 2>/dev/null; then
    {
        echo ""
        echo "## $TODAY"
        echo "**Total commits:** 0"
        echo ""
        echo "### Sessions"
        echo ""
    } >> "$WORK_LOGS"
fi

# Append session entry
{
    echo "- **$TIME** | \`${WORK_DIR##*/}\` | $STOP_REASON"
} >> "$WORK_LOGS"

exit 0
