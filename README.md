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
## Sample Output

### Normal run
```text
================ SYSTEM HEALTH REPORT ================
Date     : 2026-11-26 19:10:31
Host     : ip-172-31-6-150
Kernel   : 7.0.0-1018-aws
Uptime   : 0d 1h 52m
Load avg : 0.00 0.00 0.00 (1, 5, 15 min)

--- CPU ---
[OK]      CPU usage is 0% (limit 80%)

--- MEMORY ---
Total: 909 MB | Available: 574 MB
[OK]      Memory usage is 36% (limit 80%)

--- DISK ---
/ : 21G available
[OK]      Disk / usage is 10% (limit 80%)
/sys/firmware/efi/efivars : 120K available
[OK]      Disk /sys/firmware/efi/efivars usage is 3% (limit 80%)
/boot : 706M available
[OK]      Disk /boot usage is 14% (limit 80%)
/boot/efi : 99M available
[OK]      Disk /boot/efi usage is 6% (limit 80%)

--- TOP 5 PROCESSES BY MEMORY ---
    PID COMMAND         %CPU %MEM
   2908 fwupd            0.1  5.2
    660 snapd            0.0  4.4
    184 multipathd       0.0  2.8
    810 unattended-upgr  0.0  2.4
   1015 amazon-ssm-agen  0.0  2.2

OVERALL STATUS: HEALTHY
Report saved to: /home/ubuntu/system-health-monitor/reports/health_20261126_191031.txt
```

### Disk warning test (DISK_THRESHOLD=1)
```text
================ SYSTEM HEALTH REPORT ================
Date     : 2026-11-26 19:10:32
Host     : ip-172-31-6-150
Kernel   : 7.0.0-1018-aws
Uptime   : 0d 1h 52m
Load avg : 0.00 0.00 0.00 (1, 5, 15 min)

--- CPU ---
[OK]      CPU usage is 1% (limit 80%)

--- MEMORY ---
Total: 909 MB | Available: 574 MB
[OK]      Memory usage is 36% (limit 80%)

--- DISK ---
/ : 21G available
[WARNING] Disk / usage is 10% (limit 1%)
/sys/firmware/efi/efivars : 120K available
[WARNING] Disk /sys/firmware/efi/efivars usage is 3% (limit 1%)
/boot : 706M available
[WARNING] Disk /boot usage is 14% (limit 1%)
/boot/efi : 99M available
[WARNING] Disk /boot/efi usage is 6% (limit 1%)

--- TOP 5 PROCESSES BY MEMORY ---
    PID COMMAND         %CPU %MEM
   2908 fwupd            0.1  5.2
    660 snapd            0.0  4.4
    184 multipathd       0.0  2.8
    810 unattended-upgr  0.0  2.4
   1015 amazon-ssm-agen  0.0  2.2

OVERALL STATUS: WARNING (4 alert(s))
Report saved to: /home/ubuntu/system-health-monitor/reports/health_20261126_191032.txt
```

### Cron job
```text
*/30 * * * * "/home/ubuntu/system-health-monitor/health_check.sh" >> "/home/ubuntu/system-health-monitor/logs/cron.log" 2>&1 # system-health-monitor
```

### Run history
```text
2026-11-26 18:55:38 status=WARNING cpu=0% mem=37% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
2026-11-26 18:56:33 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 18:56:34 status=WARNING cpu=0% mem=37% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
2026-11-26 19:02:01 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 19:03:01 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 19:04:01 status=HEALTHY cpu=1% mem=37% alerts=none
2026-11-26 19:05:07 status=HEALTHY cpu=0% mem=36% alerts=none
2026-11-26 19:05:08 status=WARNING cpu=0% mem=36% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
2026-11-26 19:10:31 status=HEALTHY cpu=0% mem=36% alerts=none
2026-11-26 19:10:32 status=WARNING cpu=1% mem=36% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
```
