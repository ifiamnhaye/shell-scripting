# Crontab & RHCSA Study Notes

## 1. Crontab Kya Hota Hai?

`cron` Linux ka **time-based job scheduler** hai.

Simple alfaaz mein:

> Linux ko batana ke koi command ya script automatically kis waqt aur kitni dafa run karni hai.

Example:

```bash
*/5 * * * * /usr/bin/uptime
```

Matlab:

> Har 5 minute baad `uptime` command run karo.

RHEL/RHCSA environment mein aam tor par:

```text
cronie package
      ↓
crond service
      ↓
crontab entries
      ↓
scheduled commands automatically run
```

---

## 2. Cron Package aur Service

### Package install

```bash
dnf install cronie -y
```

### Service enable aur start

```bash
systemctl enable --now crond
```

### Service status check

```bash
systemctl status crond
```

---

## 3. Crontab Ke 5 Fields

User crontab ka basic format:

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

Sunday usually `0` ya `7` ho sakta hai.

### Easy formula

```text
Minute Hour Day Month Weekday
```

Ya:

```text
M H D M W
```

---

## 4. Important Cron Symbols

### `*`

Matlab:

> Har possible value.

Example:

```bash
* * * * * command
```

Matlab:

> Har minute command run karo.

### `*/5`

Matlab:

> Har 5 units.

Agar minute field mein ho:

```bash
*/5 * * * * command
```

Matlab:

> Har 5 minute.

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

### Monday to Friday at 8:00 AM

```bash
0 8 * * 1-5
```

### First day of every month at midnight

```bash
0 0 1 * *
```

### Every 10 minutes between 9 AM and 5 PM, Monday-Friday

```bash
*/10 9-17 * * 1-5
```

---

## 6. Crontab.guru Ka Use

Website:

```text
https://crontab.guru/
```

`crontab.guru` cron expressions ko human-readable form mein samjhane ke liye useful tool hai.

Example expression:

```text
*/5 * * * *
```

Isko site par enter karke aap verify kar sakte hain ke iska matlab:

> Every 5 minutes

hai.

### Important

`crontab.guru`:

- Cron job create nahi karta.
- Sirf cron expression ko samajhne aur verify karne mein help karta hai.
- RHCSA exam ke liye 5 fields khud yaad honi chahiye.

---

## 7. Important Crontab Commands

### Current user ka crontab edit

```bash
crontab -e
```

### Current user ke cron jobs list

```bash
crontab -l
```

### Current user ka crontab remove

```bash
crontab -r
```

> `crontab -r` poora user crontab delete kar deta hai. Carefully use karein.

### Kisi doosre user ka crontab edit

```bash
crontab -u devuser -e
```

### Kisi doosre user ka crontab list

```bash
crontab -u devuser -l
```

---

## 8. RHCSA Q9 — Uptime Every 5 Minutes

### Question

Create a cron job for user `devuser` that runs the command `uptime` every 5 minutes and saves output to:

```text
/home/devuser/uptime.log
```

### Step 1 — User check

```bash
id devuser
```

Agar user exist nahi karta aur question mein create karna required ho:

```bash
useradd devuser
```

### Step 2 — Cron package

```bash
dnf install cronie -y
```

### Step 3 — Cron service

```bash
systemctl enable --now crond
```

### Step 4 — Command path verify

```bash
which uptime
```

Usually:

```text
/usr/bin/uptime
```

### Step 5 — User crontab edit

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

### Step 6 — Verify

```bash
crontab -u devuser -l
```

### Step 7 — Output check

```bash
cat /home/devuser/uptime.log
```

---

## 9. Q9 Cron Line Explanation

```bash
*/5 * * * * /usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Breakdown:

```text
*/5      = har 5 minute
*        = har hour
*        = har day
*        = har month
*        = har weekday
```

Command:

```bash
/usr/bin/uptime
```

Output:

```bash
>> /home/devuser/uptime.log
```

Error bhi same file mein:

```bash
2>&1
```

---

## 10. `>` vs `>>`

### `>`

Overwrite karta hai.

```bash
command > file.log
```

Old content replace ho jayega.

### `>>`

Append karta hai.

```bash
command >> file.log
```

New output file ke end mein add hota rahega.

Cron history ke liye usually `>>` better hai.

---

## 11. `2>&1` Kya Hai?

Linux standard streams:

```text
0 = stdin
1 = stdout
2 = stderr
```

Command:

```bash
2>&1
```

Matlab:

> stderr ko bhi stdout wali destination par bhejo.

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

## 12. RHCSA Q10 — Logger Every Minute

### Question

Set a cron job for user `Natasha` that runs every minute and sends the message:

```text
Ex200 Testing
```

through `logger`.

> Note: "daily every 1 minute" wording confusing hai. `* * * * *` ka matlab **every minute** hai, once daily nahi.

### Step 1 — User check/create

```bash
id Natasha
```

Agar required ho:

```bash
useradd Natasha
```

### Step 2 — Cron setup

```bash
dnf install cronie -y
systemctl enable --now crond
```

### Step 3 — Logger path check

```bash
which logger
```

Usually:

```text
/usr/bin/logger
```

### Step 4 — Natasha ka crontab edit

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

### Step 5 — Verify

```bash
crontab -u Natasha -l
```

---

## 13. `logger` Command Kya Karta Hai?

`logger` message ko system logging system ko send karta hai.

Manual test:

```bash
logger "Ex200 Testing"
```

Logs check:

```bash
journalctl | grep "Ex200 Testing"
```

Cron daemon logs:

```bash
journalctl -u crond
```

Depending on distro/logging configuration:

```bash
tail -f /var/log/messages
```

Ya:

```bash
grep CRON /var/log/cron
```

---

## 14. Smart Quotes Avoid Karein

Galat:

```bash
/usr/bin/logger “Ex200 Testing”
```

Correct:

```bash
/usr/bin/logger "Ex200 Testing"
```

Bash mein normal ASCII quotes use karein.

---

## 15. User Crontab vs `/etc/crontab`

### User crontab

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

### `/etc/crontab`

Ismein extra **user field** hota hai:

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

---

## 16. RHCSA Exam Approach

Question ko 4 parts mein break karein:

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

Then:

```bash
crontab -u devuser -e
```

Add:

```bash
*/5 * * * * /usr/bin/uptime >> /home/devuser/uptime.log 2>&1
```

Verify:

```bash
crontab -u devuser -l
```

---

## 17. RHCSA Practice Questions

### Q1 — Run `/usr/bin/date` every minute

```bash
* * * * * /usr/bin/date
```

### Q2 — Run a script every 10 minutes

```bash
*/10 * * * * /path/to/script.sh
```

### Q3 — Run a backup script every day at 2:30 AM

```bash
30 2 * * * /path/to/backup.sh
```

### Q4 — Run a command every Monday at 8:00 AM

```bash
0 8 * * 1 command
```

### Q5 — Run a job Monday through Friday at 6:00 PM

```bash
0 18 * * 1-5 command
```

---

## 18. Quick Revision

```text
cron        = scheduler
crond       = cron daemon/service
cronie      = package
crontab -e  = edit
crontab -l  = list
crontab -r  = remove
-u USER     = specific user
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

## 19. Final RHCSA Tip

Cron question solve karte waqt:

1. User identify karo.
2. Schedule translate karo.
3. Full command path verify karo.
4. Crontab edit karo.
5. Save karo.
6. `crontab -l` se verify karo.
7. Logs/output check karo.

**Verification ko kabhi skip na karein.**
