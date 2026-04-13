#!/bin/bash
set -euo pipefail

LOGFILE="$HOME/rufino-cron.log"
PROMPT_FILE="$HOME/.claude/prompts/rufino-daily.md"
CLAUDE="$HOME/.local/bin/claude"

echo "=== Rufino run: $(date) ===" >> "$LOGFILE"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "ERROR: Prompt file not found at $PROMPT_FILE" >> "$LOGFILE"
    exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

"$CLAUDE" -p "$PROMPT" \
    --allowedTools "Read,Write,Edit,Glob,Grep,Bash" \
    --dangerously-skip-permissions \
    --model sonnet \
    >> "$LOGFILE" 2>&1

echo "=== Rufino done: $(date) ===" >> "$LOGFILE"
