#!/bin/bash
set -euo pipefail

# Installs the Rufino dashboard as a LaunchAgent daemon on macOS.
#
# Usage:
#   ./install-dashboard.sh <DASHBOARD_DIR> <VAULT_PATH>
#
# Arguments:
#   DASHBOARD_DIR — absolute path to the dashboard source (e.g. /Users/val/rufino-mac/dashboard)
#   VAULT_PATH    — absolute path to the Obsidian vault root
#
# Optional env vars:
#   RUFINO_DASHBOARD_PORT — defaults to 3737
#   LAUNCH_AGENT_LABEL    — defaults to com.rufino.dashboard
#
# Requires: node 20+, npm, launchctl (macOS).

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <DASHBOARD_DIR> <VAULT_PATH>" >&2
  exit 1
fi

DASHBOARD_DIR="$1"
VAULT_PATH="$2"
PORT="${RUFINO_DASHBOARD_PORT:-3737}"
LABEL="${LAUNCH_AGENT_LABEL:-com.rufino.dashboard}"

if [ ! -d "$DASHBOARD_DIR" ]; then
  echo "ERROR: dashboard directory not found: $DASHBOARD_DIR" >&2
  exit 1
fi

if [ ! -d "$VAULT_PATH" ]; then
  echo "ERROR: vault path not found: $VAULT_PATH" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node not found. Install Node.js 20+ first (https://nodejs.org)." >&2
  exit 1
fi

NODE_VERSION=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
  echo "ERROR: Node.js 20+ required. Found: $(node -v)" >&2
  exit 1
fi

echo "==> Installing dashboard dependencies…"
cd "$DASHBOARD_DIR"
npm install --silent

echo "==> Building production bundle…"
npm run build

echo "==> Writing LaunchAgent plist…"
PLIST_PATH="$HOME/Library/LaunchAgents/${LABEL}.plist"
mkdir -p "$HOME/Library/LaunchAgents"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${DASHBOARD_DIR}/scripts/run-daemon.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>${DASHBOARD_DIR}</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>RUFINO_VAULT_PATH</key>
        <string>${VAULT_PATH}</string>
        <key>RUFINO_DASHBOARD_PORT</key>
        <string>${PORT}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${HOME}/rufino-dashboard.log</string>
    <key>StandardErrorPath</key>
    <string>${HOME}/rufino-dashboard.err.log</string>
</dict>
</plist>
PLIST

chmod +x "$DASHBOARD_DIR/scripts/run-daemon.sh"

echo "==> Loading LaunchAgent (${LABEL})…"
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

sleep 2

echo ""
echo "==> Verifying daemon is up…"
for i in 1 2 3 4 5; do
  if curl -sf -o /dev/null "http://localhost:${PORT}"; then
    echo "✓ Dashboard is live at http://localhost:${PORT}"
    exit 0
  fi
  sleep 2
done

echo "⚠ Dashboard did not respond on port ${PORT} within 10s."
echo "  Check logs: tail -f ~/rufino-dashboard.log ~/rufino-dashboard.err.log"
exit 1
