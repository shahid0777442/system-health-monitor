# Cron Output
```
*/30 * * * * "/home/ubuntu/system-health-monitor/health_check.sh" >> "/home/ubuntu/system-health-monitor/logs/cron.log" 2>&1 # system-health-monitor

Uptime   : 0d 1h 45m
Load avg : 0.00 0.00 0.00 (1, 5, 15 min)

--- CPU ---
[OK]      CPU usage is 1% (limit 80%)

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
   2908 fwupd            0.1  5.2
    660 snapd            0.0  4.4
    184 multipathd       0.0  2.8
    810 unattended-upgr  0.0  2.4
   1015 amazon-ssm-agen  0.0  2.2

OVERALL STATUS: HEALTHY
Report saved to: /home/ubuntu/system-health-monitor/reports/health_20261126_190401.txt
```
