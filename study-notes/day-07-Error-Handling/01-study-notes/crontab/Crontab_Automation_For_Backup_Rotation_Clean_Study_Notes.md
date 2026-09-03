# Automating a Bash Backup Rotation Script with Crontab

## Goal

Automate the backup rotation script so that it runs automatically with `cron`.

For quick testing, use:

```cron
* * * * *
```

This means:

> Run the job every minute.

---

# 1. Make the Script Executable

```bash
chmod +x backup.sh
```

Check:

```bash
ls -l backup.sh
```

You should see execute permission, for example:

```text
-rwxr-xr-x
```

---

# 2. Find the Full Path of the Script

```bash
realpath backup.sh
```

Example:

```text
/home/khalid/backup-project/backup.sh
```

Cron jobs should use full absolute paths.

---

# 3. Find the Full Paths of Source and Backup Directories

```bash
realpath data
realpath backups
```

Example:

```text
/home/khalid/backup-project/data
/home/khalid/backup-project/backups
```

---

# 4. Test the Script Manually First

```bash
/home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups
```

If the backup is created successfully, the command is ready for cron.

---

# 5. Open Crontab

```bash
crontab -e
```

This opens the cron configuration for the current user.

---

# 6. Run the Backup Every Minute

Add:

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups
```

Meaning:

> Every minute, run `backup.sh` with the source and backup folder as arguments.

---

# 7. Understanding `* * * * *`

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └── Day of week
│ │ │ └──── Month
│ │ └────── Day of month
│ └──────── Hour
└────────── Minute
```

So:

```cron
* * * * *
```

means:

```text
Every minute
Every hour
Every day
Every month
Every weekday
```

---

# 8. Recommended Cron Entry with Logging

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

This saves normal output and errors into:

```text
backup-cron.log
```

---

# 9. Why Use `>>`?

```bash
>>
```

means:

> Append output to the end of a file.

Example:

```bash
command >> logfile
```

Old content stays, and new output is added at the end.

---

# 10. Why Use `2>&1`?

Linux standard streams:

```text
1 = stdout
2 = stderr
```

This:

```bash
2>&1
```

means:

> Send standard error to the same place as standard output.

So:

```bash
>> backup-cron.log 2>&1
```

means:

```text
stdout ─┐
        ├──→ backup-cron.log
stderr ─┘
```

---

# 11. Check the Cron Log

```bash
cat /home/khalid/backup-project/backup-cron.log
```

Live view:

```bash
tail -f /home/khalid/backup-project/backup-cron.log
```

---

# 12. Verify the Cron Job

```bash
crontab -l
```

You should see your scheduled entry.

---

# 13. Check the Cron Service

## Ubuntu / Debian / WSL

```bash
systemctl status cron
```

If needed:

```bash
sudo systemctl enable --now cron
```

## RHEL / Rocky / AlmaLinux / RHCSA

```bash
systemctl status crond
```

If needed:

```bash
sudo systemctl enable --now crond
```

---

# 14. Why Full Paths Matter

Avoid:

```cron
* * * * * ./backup.sh ./data ./backups
```

Cron may not start from your current working directory.

Use:

```cron
* * * * * /full/path/backup.sh /full/path/data /full/path/backups
```

---

# 15. How Rotation Behaves Every Minute

If the script keeps the latest 5 backups:

```text
Minute 1 → backup 1
Minute 2 → backup 2
Minute 3 → backup 3
Minute 4 → backup 4
Minute 5 → backup 5
Minute 6 → backup 6
             ↓
          rotation
             ↓
       oldest backup removed
```

Important:

> This keeps the latest 5 backup files, not 5 days.

---

# 16. Quick Demo

Use:

```cron
* * * * *
```

Then watch the backup directory:

```bash
watch ls -lt /home/khalid/backup-project/backups
```

New ZIP files appear every minute, and the oldest file is removed after the retention limit is exceeded.

---

# 17. Real-World Example: Daily at 2:00 AM

```cron
0 2 * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

Meaning:

> Run every day at 2:00 AM.

---

# 18. Every 5 Minutes

```cron
*/5 * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups
```

Meaning:

```text
00
05
10
15
20
25
...
```

---

# 19. Prevent Overlapping Backup Jobs

If a backup takes longer than one minute, the next cron run may start while the previous one is still running.

Use `flock`:

```cron
* * * * * flock -n /tmp/backup_rotation.lock /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

---

# 20. What Does `flock` Do?

`flock` uses a lock file:

```text
/tmp/backup_rotation.lock
```

Flow:

```text
Cron starts
    ↓
Try to get lock
    ↓
Is another backup already running?
 ┌───────┴────────┐
Yes               No
↓                  ↓
Skip             Run backup
```

### `-n`

```bash
-n
```

means:

> Do not wait for the lock. If another job already has it, exit immediately.

---

# 21. Suggested Learning Progression

```text
Level 1
Run backup manually
        ↓
Level 2
Add cron: * * * * *
        ↓
Level 3
Redirect output to a log
        ↓
Level 4
Use a real schedule: 0 2 * * *
        ↓
Level 5
Prevent overlap with flock
```

---

# 22. Useful Cron Commands

Edit:

```bash
crontab -e
```

List:

```bash
crontab -l
```

Remove the entire current user's crontab:

```bash
crontab -r
```

Be careful with `crontab -r`.

---

# 23. Troubleshooting

If the job does not run:

```bash
crontab -l
```

Check the cron service.

Ubuntu:

```bash
systemctl status cron
```

RHEL:

```bash
systemctl status crond
```

If the script works manually but not from cron, check:

1. Are you using full paths?
2. Is the script executable?
3. Does the cron user have permission?
4. Is `zip` installed?
5. Is the backup directory writable?
6. Check the cron log file.

RHEL cron logs:

```bash
journalctl -u crond
```

On systems with `/var/log/cron`:

```bash
tail -f /var/log/cron
```

---

# 24. Quick Revision

```text
crontab -e      = edit cron jobs
crontab -l      = list cron jobs

* * * * *       = every minute
*/5 * * * *     = every 5 minutes
0 2 * * *       = every day at 2:00 AM

>>              = append output
2>&1            = send stderr to stdout destination

full paths      = recommended in cron

flock           = prevent overlapping jobs
```

---

# 25. Final Flow

```text
Cron Scheduler
      ↓
Every Minute
      ↓
Run backup.sh
      ↓
Create timestamped ZIP
      ↓
Count backups
      ↓
Keep latest 5
      ↓
Remove older backups
      ↓
Write output to log
```

---

# Recommended Testing Cron Entry

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

# Safer Version with `flock`

```cron
* * * * * flock -n /tmp/backup_rotation.lock /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```
