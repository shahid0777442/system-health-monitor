# Output
## Health check
```
================ SYSTEM HEALTH REPORT ================
Date     : 2026-11-26 18:56:33
Host     : ip-172-31-6-150
Kernel   : 7.0.0-1018-aws
Uptime   : 0d 1h 38m
Load avg : 0.00 0.00 0.00 (1, 5, 15 min)

--- CPU ---
[OK]      CPU usage is 0% (limit 80%)

--- MEMORY ---
Total: 909 MB | Available: 568 MB
[OK]      Memory usage is 37% (limit 80%)

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
   2908 fwupd            0.2  5.2
    660 snapd            0.0  4.4
    184 multipathd       0.0  2.8
    810 unattended-upgr  0.0  2.4
   1015 amazon-ssm-agen  0.0  2.2

OVERALL STATUS: HEALTHY
Report saved to: /home/ubuntu/system-health-monitor/reports/health_20261126_185633.txt
```
## Disk warning test (DISK_THRESHOLD=1)
```
================ SYSTEM HEALTH REPORT ================
Date     : 2026-11-26 18:56:34
Host     : ip-172-31-6-150
Kernel   : 7.0.0-1018-aws
Uptime   : 0d 1h 38m
Load avg : 0.00 0.00 0.00 (1, 5, 15 min)

--- CPU ---
[OK]      CPU usage is 0% (limit 80%)

--- MEMORY ---
Total: 909 MB | Available: 568 MB
[OK]      Memory usage is 37% (limit 80%)

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
   2908 fwupd            0.2  5.2
    660 snapd            0.0  4.4
    184 multipathd       0.0  2.8
    810 unattended-upgr  0.0  2.4
   1015 amazon-ssm-agen  0.0  2.2

OVERALL STATUS: WARNING (4 alert(s))
Report saved to: /home/ubuntu/system-health-monitor/reports/health_20261126_185634.txt
```
## Cron jobs
```
no crontab for ubuntu
```
## Log (last 20 lines)
```
2026-11-26 18:55:03 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 18:55:20 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 18:55:38 status=WARNING cpu=0% mem=37% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
2026-11-26 18:56:33 status=HEALTHY cpu=0% mem=37% alerts=none
2026-11-26 18:56:34 status=WARNING cpu=0% mem=37% alerts=Disk /=10% Disk /sys/firmware/efi/efivars=3% Disk /boot=14% Disk /boot/efi=6%
```
