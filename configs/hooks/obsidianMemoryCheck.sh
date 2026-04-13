#!/bin/bash
set -euo pipefail

HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
FLAG="/tmp/claude-memory-check-${SESSION_ID}"

if [ -f "$FLAG" ]; then
    rm -f "$FLAG"
    exit 0
fi

touch "$FLAG"
echo "OBSIDIAN MEMORY CHECK: revisá si hay algo para guardar en el vault antes de cerrar." >&2
exit 2
