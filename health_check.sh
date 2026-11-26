#!/usr/bin/env bash
# health_check.sh - checks CPU, memory and disk usage and writes a health report.
# Exit codes: 0 = healthy, 1 = at least one warning, 2 = script error

set -u
set -o pipefail

# Cron runs with a minimal environment, so set these explicitly.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LC_ALL=C

# Thresholds in percent. Override like: DISK_THRESHOLD=50 ./health_check.sh
CPU_THRESHOLD="${CPU_THRESHOLD:-80}"
MEM_THRESHOLD="${MEM_THRESHOLD:-80}"
DISK_THRESHOLD="${DISK_THRESHOLD:-80}"

for value in "$CPU_THRESHOLD" "$MEM_THRESHOLD" "$DISK_THRESHOLD"; do
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "ERROR: thresholds must be whole numbers, got '$value'" >&2
        exit 2
    fi
done

# Paths are relative to the script, not to the current directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
REPORT_DIR="$SCRIPT_DIR/reports"
mkdir -p "$LOG_DIR" "$REPORT_DIR" || exit 2

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
REPORT_FILE="$REPORT_DIR/health_$(date '+%Y%m%d_%H%M%S').txt"
LOG_FILE="$LOG_DIR/health.log"
ALERTS=()

# Colors only when printing to a terminal (keeps log files clean).
if [[ -t 1 ]]; then
    RED=$'\033[1;31m'; GREEN=$'\033[1;32m'; RESET=$'\033[0m'
else
    RED=""; GREEN=""; RESET=""
fi

# Print to the terminal and save the same line (without color) in the report.
say() {
    echo "$1"
    echo "$1" >> "$REPORT_FILE"
}

# check LABEL VALUE THRESHOLD - warns if VALUE is above THRESHOLD
check() {
    local label="$1" value="$2" limit="$3" line
    if (( value > limit )); then
        line="[WARNING] $label usage is ${value}% (limit ${limit}%)"
        ALERTS+=("$label=${value}%")
        echo "${RED}${line}${RESET}"
    else
        line="[OK]      $label usage is ${value}% (limit ${limit}%)"
        echo "${GREEN}${line}${RESET}"
    fi
    echo "$line" >> "$REPORT_FILE"
}

# CPU: read the counters in /proc/stat twice, one second apart.
read_cpu() {
    # prints: total_time idle_time (idle includes iowait)
    awk '/^cpu / { total=0; for (i=2; i<=9; i++) total+=$i; print total, $5+$6 }' /proc/stat
}

cpu_usage() {
    local total1 idle1 total2 idle2
    read -r total1 idle1 <<< "$(read_cpu)"
    sleep 1
    read -r total2 idle2 <<< "$(read_cpu)"
    awk -v t=$((total2 - total1)) -v i=$((idle2 - idle1)) \
        'BEGIN { if (t <= 0) print 0; else printf "%.0f\n", (t - i) * 100 / t }'
}

if [[ ! -r /proc/stat || ! -r /proc/meminfo ]]; then
    echo "ERROR: this script needs Linux (/proc/stat and /proc/meminfo)" >&2
    exit 2
fi

say "================ SYSTEM HEALTH REPORT ================"
say "Date     : $TIMESTAMP"
say "Host     : $(uname -n)"
say "Kernel   : $(uname -r)"
say "Uptime   : $(awk '{ printf "%dd %dh %dm", $1/86400, ($1%86400)/3600, ($1%3600)/60 }' /proc/uptime)"
say "Load avg : $(awk '{ print $1, $2, $3 }' /proc/loadavg) (1, 5, 15 min)"

say ""
say "--- CPU ---"
CPU=$(cpu_usage)
check "CPU" "$CPU" "$CPU_THRESHOLD"

say ""
say "--- MEMORY ---"
read -r MEM_TOTAL MEM_AVAIL <<< "$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print t, a}' /proc/meminfo)"
MEM_USED_PCT=$(( (MEM_TOTAL - MEM_AVAIL) * 100 / MEM_TOTAL ))
say "Total: $((MEM_TOTAL / 1024)) MB | Available: $((MEM_AVAIL / 1024)) MB"
check "Memory" "$MEM_USED_PCT" "$MEM_THRESHOLD"

say ""
say "--- DISK ---"
DISK_COUNT=0
# Skip temporary and read-only image filesystems.
while IFS='|' read -r pct avail mount; do
    say "$mount : $avail available"
    check "Disk $mount" "$pct" "$DISK_THRESHOLD"
    DISK_COUNT=$((DISK_COUNT + 1))
done < <(df -P -h -x tmpfs -x devtmpfs -x squashfs 2>/dev/null | awk '
    NR > 1 {
        for (i = 2; i <= NF; i++) if ($i ~ /^[0-9]+%$/) {
            mount = $(i+1)
            for (j = i+2; j <= NF; j++) mount = mount " " $j
            pct = $i; sub(/%/, "", pct)
            print pct "|" $(i-1) "|" mount
            break
        }
    }')

if (( DISK_COUNT == 0 )); then
    say "[WARNING] Could not read any disk information"
    ALERTS+=("disk=unreadable")
fi

say ""
say "--- TOP 5 PROCESSES BY MEMORY ---"
say "$(ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6)"

say ""
if (( ${#ALERTS[@]} == 0 )); then
    STATUS="HEALTHY"
    say "OVERALL STATUS: HEALTHY"
    EXIT_CODE=0
else
    STATUS="WARNING"
    say "OVERALL STATUS: WARNING (${#ALERTS[@]} alert(s))"
    EXIT_CODE=1
fi

# One summary line per run, useful for seeing history.
echo "$TIMESTAMP status=$STATUS cpu=${CPU}% mem=${MEM_USED_PCT}% alerts=${ALERTS[*]:-none}" >> "$LOG_FILE"

# Delete reports older than 7 days.
find "$REPORT_DIR" -type f -name 'health_*.txt' -mtime +7 -delete

echo "Report saved to: $REPORT_FILE"
exit "$EXIT_CODE"
