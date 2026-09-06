# Crontab & RHCSA Study Notes

## 1. What Is Crontab?

`cron` is a **time-based job scheduler** in Linux.

In simple words:

> You tell Linux which command or script should run automatically, at what time, and how often.

Example:

```bash
*/5 * * * * /usr/bin/uptime
```

Meaning:

> Run the `uptime` command every 5 minutes.

In a RHEL/RHCSA environment, the usual flow is:

```text
cronie package
      ↓
crond service
      ↓
crontab entries
      ↓
scheduled commands run automatically
```

---

## 2. Cron Package and Service

### Install the package

```bash
dnf install cronie -y
```

### Enable and start the service

```bash
systemctl enable --now crond
```

### Check service status

```bash
systemctl status crond
```

---

## 3. The 5 Crontab Fields

A user crontab follows this basic format:

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └── Day of week
│ │ │ └──── Month
│ │ └────── Day of month
│ └──────── Hour
└────────── Minute
```

| Field | Meaning | Range |
|---|---|---|
| 1 | Minute | 0–59 |
| 2 | Hour | 0–23 |
| 3 | Day of Month | 1–31 |
| 4 | Month | 1–12 |
| 5 | Day of Week | 0–7 |

Sunday is commonly represented by `0` or `7`.

### Easy memory formula

```text
Minute Hour Day Month Weekday
```

Or:

```text
M H D M W
```

---

## 4. Important Cron Symbols

### `*`

Means:

> Every possible value.

Example:

```bash
* * * * * command
```

Meaning:

> Run the command every minute.

### `*/5`

Means:

> Every 5 units.

If it is in the minute field:

```bash
*/5 * * * * command
```

Meaning:

> Run every 5 minutes.

### Common operators

```text
*       = every value
*/5     = every 5
1,5,10  = specific values
1-5     = range
```

---

## 5. Common Cron Examples

### Every 5 minutes

```bash
*/5 * * * *
```

### Every hour

```bash
0 * * * *
```

### Every day at 8:30 AM

```bash
30 8 * * *
```

### Every day at 10:00 PM

```bash
0 22 * * *
```

### Monday through Friday at 8:00 AM

```bash
0 8 * * 1-5
```

### First day of every month at midnight

```bash
0 0 1 * *
```

### Every 10 minutes between 9 AM and 5 PM, Monday through Friday

```bash
*/10 9-17 * * 1-5
```

---

# 6. How to Use Crontab.guru

Website:

```text
https://crontab.guru/
```

`crontab.guru` is a helpful tool for understanding and checking cron expressions.

Example expression:

```text
*/5 * * * *
```

If you enter this expression into crontab.guru, it explains that the schedule means:

> Every 5 minutes

### Important

`crontab.guru`:

- Does not create the cron job for you.
- Helps you understand or verify a cron expression.
- Should be used as a learning and checking tool.
- Does not replace learning the five cron fields for RHCSA.

---

# 7. Important Crontab Commands

### Edit the current user's crontab

```bash
crontab -e
```

### List the current user's cron jobs

```bash
crontab -l
```

### Remove the current user's crontab

```bash
crontab -r
```

> Be careful: `crontab -r` removes the entire crontab for that user.

### Edit another user's crontab

```bash
crontab -u devuser -e
```

### List another user's crontab

```bash
crontab -u devuser -l
```

---

# 8. RHCSA Q9 — Run Uptime Every 5 Minutes

## Question

Create a cron job for user `devuser` that runs the command `uptime` every 5 minutes and saves the output to:

```text
/home/devuser/uptime.log
```

## Step 1 — Check the user

```bash
id devuser
```

If the user does not exist and the question requires you to create it:

```bash
useradd devuser
```

## Step 2 — Install Cron

```bash
dnf install cronie -y
```

## Step 3 — Enable and start Cron

```bash
systemctl enable --now crond
```

## Step 4 — Verify the command path

```bash
which uptime
```

Usually:

```text
/usr/bin/uptime
```

## Step 5 — Edit the user's crontab

```bash
crontab -u devuser -e
```

Add:

```bash
*/5 * * * * /usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Save in Vim:

```text
:wq
```

## Step 6 — Verify the cron job

```bash
crontab -u devuser -l
```

## Step 7 — Check the output

```bash
cat /home/devuser/uptime.log
```

---

# 9. Explanation of the Q9 Cron Line

```bash
*/5 * * * * /usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Breakdown:

```text
*/5      = every 5 minutes
*        = every hour
*        = every day
*        = every month
*        = every weekday
```

Command:

```bash
/usr/bin/uptime
```

Append the normal output to:

```bash
>> /home/devuser/uptime.log
```

Send errors to the same destination:

```bash
2>&1
```

---

# 10. `>` vs `>>`

### `>`

Overwrites the file.

```bash
command > file.log
```

Existing content is replaced.

### `>>`

Appends to the file.

```bash
command >> file.log
```

New output is added to the end of the file.

For cron logs and historical output, `>>` is usually the better choice.

---

# 11. What Does `2>&1` Mean?

Linux standard streams:

```text
0 = stdin
1 = stdout
2 = stderr
```

This:

```bash
2>&1
```

means:

> Send standard error to the same place as standard output.

Example:

```bash
/usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Flow:

```text
stdout ─┐
        ├──→ uptime.log
stderr ─┘
```

---

# 12. RHCSA Q10 — Use Logger Every Minute

## Question

Set a cron job for user `Natasha` that runs every minute and sends the message:

```text
Ex200 Testing
```

using the `logger` command.

> Note: The wording "daily every 1 minute" is confusing.  
> `* * * * *` means **every minute**, not once daily.

## Step 1 — Check or create the user

```bash
id Natasha
```

If required:

```bash
useradd Natasha
```

## Step 2 — Configure Cron

```bash
dnf install cronie -y
systemctl enable --now crond
```

## Step 3 — Check the logger path

```bash
which logger
```

Usually:

```text
/usr/bin/logger
```

## Step 4 — Edit Natasha's crontab

```bash
crontab -u Natasha -e
```

Add:

```bash
* * * * * /usr/bin/logger "Ex200 Testing"
```

Save:

```text
:wq
```

## Step 5 — Verify

```bash
crontab -u Natasha -l
```

---

# 13. What Does the `logger` Command Do?

`logger` sends a message to the system logging system.

Manual test:

```bash
logger "Ex200 Testing"
```

Check logs:

```bash
journalctl | grep "Ex200 Testing"
```

Check the cron daemon:

```bash
journalctl -u crond
```

Depending on the distribution and logging configuration, you may also use:

```bash
tail -f /var/log/messages
```

or:

```bash
grep CRON /var/log/cron
```

---

# 14. Avoid Smart Quotes

Incorrect:

```bash
/usr/bin/logger “Ex200 Testing”
```

These are smart quotes:

```text
“ ”
```

Correct:

```bash
/usr/bin/logger "Ex200 Testing"
```

Use normal ASCII quotes in Bash:

```text
" "
```

---

# 15. User Crontab vs `/etc/crontab`

## User crontab

Command:

```bash
crontab -e
```

Format:

```text
minute hour day month weekday command
```

Example:

```bash
*/5 * * * * /usr/bin/uptime
```

## `/etc/crontab`

`/etc/crontab` includes an additional **user field**:

```text
minute hour day month weekday USER command
```

Example:

```bash
*/5 * * * * devuser /usr/bin/uptime
```

### Important difference

```text
crontab -e
5 schedule fields + command
```

```text
/etc/crontab
5 schedule fields + USER + command
```

This is a useful RHCSA and interview question.

---

# 16. RHCSA Exam Approach

Break the question into four parts:

```text
WHO?
WHEN?
WHAT?
WHERE?
```

Example:

> Configure a cron job for `devuser` to run `/usr/bin/uptime` every 5 minutes and save output to `/home/devuser/uptime.log`.

Breakdown:

```text
WHO?
devuser

WHEN?
every 5 minutes

WHAT?
/usr/bin/uptime

WHERE?
/home/devuser/uptime.log
```

Then edit:

```bash
crontab -u devuser -e
```

Add:

```bash
*/5 * * * * /usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Finally verify:

```bash
crontab -u devuser -l
```

---

# 17. RHCSA Practice Questions

## Q1

Run `/usr/bin/date` every minute.

```bash
* * * * * /usr/bin/date
```

## Q2

Run a script every 10 minutes.

```bash
*/10 * * * * /path/to/script.sh
```

## Q3

Run a backup script every day at 2:30 AM.

```bash
30 2 * * * /path/to/backup.sh
```

## Q4

Run a command every Monday at 8:00 AM.

```bash
0 8 * * 1 command
```

## Q5

Run a job Monday through Friday at 6:00 PM.

```bash
0 18 * * 1-5 command
```

---

# 18. Quick Revision

```text
cron        = scheduler
crond       = cron daemon/service
cronie      = package
crontab -e  = edit
crontab -l  = list
crontab -r  = remove
-u USER     = work with a specific user's crontab
```

Cron fields:

```text
Minute Hour Day Month Weekday
```

Every 5 minutes:

```bash
*/5 * * * *
```

Every minute:

```bash
* * * * *
```

Daily at 8 AM:

```bash
0 8 * * *
```

Append output:

```bash
>>
```

Redirect stderr to stdout:

```bash
2>&1
```

---

# 19. Final RHCSA Tip

When solving a cron question:

1. Identify the user.
2. Translate the schedule correctly.
3. Verify the full command path.
4. Edit the correct crontab.
5. Save the entry.
6. Verify it with `crontab -l`.
7. Check logs or output.

**Never skip verification.**
