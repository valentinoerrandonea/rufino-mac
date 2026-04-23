#!/bin/bash
set -euo pipefail

# Dashboard daemon wrapper. Run from the dashboard root via LaunchAgent.

cd "$(dirname "$0")/.."
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
export NODE_ENV=production
export PORT="${RUFINO_DASHBOARD_PORT:-3737}"

# RUFINO_VAULT_PATH must be set by the LaunchAgent (or inherited from environment).
if [ -z "${RUFINO_VAULT_PATH:-}" ]; then
  echo "ERROR: RUFINO_VAULT_PATH is not set" >&2
  exit 1
fi

LOGFILE="$HOME/rufino-dashboard.log"
echo "=== Rufino dashboard starting: $(date) ===" >> "$LOGFILE"

exec npm run start >> "$LOGFILE" 2>&1
