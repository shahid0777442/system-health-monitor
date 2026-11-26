# Linux System Health Monitor

Bash scripts that check CPU, memory and disk usage, raise alerts, write reports and run on a schedule with cron.

## Files
| File | Purpose |
|---|---|
| `health_check.sh` | Runs the checks and writes a report |
| `install_cron.sh` | Adds or removes the cron job |
| `sample_logs/` | Example output |

## Requirements
Linux (Ubuntu, Debian, Fedora or WSL), Bash, cron, Git.

## Usage
```bash
chmod +x health_check.sh install_cron.sh
./health_check.sh
```

Alerts appear when usage is **above** the limit (default 80%). To change a limit:
```bash
DISK_THRESHOLD=90 CPU_THRESHOLD=70 ./health_check.sh
```

## Output
- `reports/health_YYYYMMDD_HHMMSS.txt`: full report per run (removed after 7 days)
- `logs/health.log`: one summary line per run
- `logs/cron.log`: output of scheduled runs

Exit codes: `0` healthy, `1` warning, `2` script error.

## Scheduling
```bash
./install_cron.sh                 # every 30 minutes
./install_cron.sh "0 9 * * *"     # daily at 09:00
./install_cron.sh --remove        # stop
crontab -l                        # view jobs
```
Cron field order: `minute hour day-of-month month day-of-week`.

## Troubleshooting
- Cron not running: `sudo systemctl enable --now cron` (Fedora: `crond`). On WSL without systemd: `sudo service cron start`.
- `bad interpreter` or `$'\r'` errors: the file has Windows line endings. Fix with `sed -i 's/\r$//' *.sh`.
