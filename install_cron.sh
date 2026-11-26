#!/usr/bin/env bash
# install_cron.sh - schedule health_check.sh with cron.
# Usage: ./install_cron.sh            (every 30 minutes)
#        ./install_cron.sh "0 9 * * *" (daily at 09:00)
#        ./install_cron.sh --remove

set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/health_check.sh"
MARKER="# system-health-monitor"
SCHEDULE="${1:-*/30 * * * *}"

command -v crontab >/dev/null || { echo "ERROR: cron is not installed" >&2; exit 1; }

# Keep all other cron jobs; drop only our previous entry.
CURRENT="$(crontab -l 2>/dev/null || true)"
OTHERS="$(printf '%s\n' "$CURRENT" | grep -vF "$MARKER" || true)"

if [[ "$SCHEDULE" == "--remove" ]]; then
    printf '%s\n' "$OTHERS" | crontab -
    echo "Cron job removed."
    exit 0
fi

mkdir -p "$SCRIPT_DIR/logs"
chmod +x "$SCRIPT"
JOB="$SCHEDULE \"$SCRIPT\" >> \"$SCRIPT_DIR/logs/cron.log\" 2>&1 $MARKER"

printf '%s\n%s\n' "$OTHERS" "$JOB" | sed '/^$/d' | crontab -
echo "Cron job installed:"
crontab -l | grep -F "$MARKER"
