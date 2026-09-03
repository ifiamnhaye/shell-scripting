# Bash Backup Rotation Script ko Crontab ke Sath Automate Karna — Roman Urdu Study Notes

## Goal

Backup rotation script ko `cron` ke zariye automatically run karwana.

Classroom testing ke liye hum use karenge:

```cron
* * * * *
```

Iska matlab:

> Job har 1 minute run hogi.

---

# 1. Script ko Executable Banayein

Suppose aapki script ka naam hai:

```text
backup.sh
```

Usko executable banayein:

```bash
chmod +x backup.sh
```

Check karein:

```bash
ls -l backup.sh
```

Aapko execute permission nazar aani chahiye, example:

```text
-rwxr-xr-x
```

---

# 2. Script ka Full Path Nikalein

Use:

```bash
realpath backup.sh
```

Example:

```text
/home/khalid/backup-project/backup.sh
```

Cron jobs mein **full absolute paths** use karna best practice hai.

---

# 3. Source aur Backup Directories ke Full Paths Nikalein

Example:

```bash
realpath data
```

Possible output:

```text
/home/khalid/backup-project/data
```

Phir:

```bash
realpath backups
```

Possible output:

```text
/home/khalid/backup-project/backups
```

Ab hamare paas:

```text
Script:
 /home/khalid/backup-project/backup.sh

Source:
 /home/khalid/backup-project/data

Backup folder:
 /home/khalid/backup-project/backups
```

---

# 4. Cron se Pehle Script ko Manually Test Karein

Cron mein add karne se pehle full command manually test karein.

Example:

```bash
/home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups
```

Agar backup successfully create ho jaye, to command cron ke liye ready hai.

---

# 5. Current User ka Crontab Open Karein

Run:

```bash
crontab -e
```

Ye current user ki cron configuration open karega.

---

# 6. Har Minute Backup Run Karna

Crontab mein ye line add karein:

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups
```

Iska matlab:

> Har minute `backup.sh` run karo aur source aur backup folder ko arguments ke taur par pass karo.

---

# 7. `* * * * *` ko Samjhein

Cron entry mein 5 scheduling fields hoti hain:

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
Har minute
Har hour
Har day
Har month
Har weekday
```

Yani:

> Job har minute run hogi.

---

# 8. Logging ke Sath Recommended Cron Entry

Better version:

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

Ye script ka normal output aur errors dono save karega:

```text
backup-cron.log
```

mein.

---

# 9. `>>` Kyun Use Karte Hain?

```bash
>>
```

ka matlab:

> Output ko file ke end mein append karo.

Example:

```bash
command >> logfile
```

Purana content rehta hai aur naya output neeche add hota rehta hai.

Cron history ke liye ye useful hai.

---

# 10. `2>&1` Kya Karta Hai?

Linux standard streams:

```text
1 = stdout
2 = stderr
```

Ye:

```bash
2>&1
```

means:

> Error output ko bhi wahi bhejo jahan normal output ja raha hai.

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

# 11. Cron Log Check Karein

Read karne ke liye:

```bash
cat /home/khalid/backup-project/backup-cron.log
```

Live dekhne ke liye:

```bash
tail -f /home/khalid/backup-project/backup-cron.log
```

---

# 12. Cron Job Verify Karein

Run:

```bash
crontab -l
```

Aapko scheduled job nazar aani chahiye.

Example:

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

---

# 13. Cron Service Check Karein

## Ubuntu / Debian / WSL

Check:

```bash
systemctl status cron
```

Agar needed ho:

```bash
sudo systemctl enable --now cron
```

---

## RHEL / Rocky / AlmaLinux / RHCSA

Check:

```bash
systemctl status crond
```

Agar needed ho:

```bash
sudo systemctl enable --now crond
```

---

# 14. Cron Mein Full Paths Kyun Zaroori Hain?

Ye avoid karein:

```cron
* * * * * ./backup.sh ./data ./backups
```

Ye reliable nahi hai kyun ke cron aapki current terminal directory se run hona guaranteed nahi hota.

Better:

```cron
* * * * * /full/path/backup.sh /full/path/data /full/path/backups
```

Full paths zyada safe aur predictable hain.

---

# 15. Har Minute Rotation Kaise Behave Karegi?

Agar script latest 5 backups rakhti hai:

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
       oldest backup remove
```

Important:

> Ye latest 5 **backup files** rakhta hai, latest 5 days nahi.

---

# 16. Classroom Demo Idea

Lecture ke liye:

```cron
* * * * *
```

bohat acha hai kyun ke students result quickly dekh sakte hain.

Suggested demo:

1. Cron job add karein.
2. Run:

```bash
watch ls -lt /home/khalid/backup-project/backups
```

3. Kuch minutes wait karein.
4. Naye ZIP files create hote dekhein.
5. Jab 5 se zyada backups ho jayein, oldest file remove hoti dekhein.

Is se cron + rotation visually clear ho jati hai.

---

# 17. Real-World Example: Roz 2:00 AM

Real backup schedule ke liye har minute run karna usually zaroori nahi hota.

Roz 2:00 AM:

```cron
0 2 * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

Breakdown:

```text
0 = minute 0
2 = hour 2
* = har day
* = har month
* = har weekday
```

Meaning:

> Har din 2:00 AM par run karo.

---

# 18. Har 5 Minute

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

Yani:

> Har 5 minute.

---

# 19. Overlapping Backup Jobs se Bachna

Possible issue:

```text
Cron har minute run hota hai
        ↓
Backup ko 1 minute se zyada lagta hai
        ↓
Next cron run start ho jata hai
        ↓
Do backups ek hi waqt run kar rahe hain
```

Isko **overlapping job** kehte hain.

Iske liye `flock` useful hai.

Example:

```cron
* * * * * flock -n /tmp/backup_rotation.lock /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

---

# 20. `flock` Kya Karta Hai?

`flock` lock file use karta hai.

Example:

```text
/tmp/backup_rotation.lock
```

Flow:

```text
Cron start
    ↓
Lock lene ki koshish
    ↓
Kya previous backup abhi run ho raha hai?
 ┌────────┴─────────┐
Yes                No
↓                    ↓
Skip               Backup run
```

### `-n`

```bash
-n
```

means:

> Lock available na ho to wait mat karo, seedha exit kar do.

---

# 21. Suggested Learning Progression

Teaching ke liye:

```text
Level 1
Backup manually run karo

        ↓

Level 2
Cron add karo:
* * * * *

        ↓

Level 3
Output log file mein bhejo

        ↓

Level 4
Real schedule use karo:
0 2 * * *

        ↓

Level 5
flock se overlap prevent karo
```

---

# 22. Useful Cron Commands

Crontab edit:

```bash
crontab -e
```

Cron jobs list:

```bash
crontab -l
```

Current user ka poora crontab remove:

```bash
crontab -r
```

Careful:

```bash
crontab -r
```

poori cron entries remove kar deta hai.

---

# 23. Troubleshooting

## Job Run Nahi Ho Rahi

Check:

```bash
crontab -l
```

Phir service check karein.

Ubuntu:

```bash
systemctl status cron
```

RHEL:

```bash
systemctl status crond
```

---

## Script Manual Run Hoti Hai Lekin Cron se Nahi

Check karein:

1. Kya full paths use kiye hain?
2. Kya script executable hai?
3. Kya cron user ke paas permission hai?
4. Kya `zip` installed hai?
5. Kya backup directory writable hai?
6. Log file check karein.

---

## RHEL Cron Logs

```bash
journalctl -u crond
```

Agar system `/var/log/cron` use karta ho:

```bash
tail -f /var/log/cron
```

---

# 24. Quick Revision

```text
crontab -e      = cron jobs edit karo
crontab -l      = cron jobs list karo

* * * * *       = har minute
*/5 * * * *     = har 5 minute
0 2 * * *       = har din 2:00 AM

>>              = output append karo
2>&1            = stderr ko stdout wali destination par bhejo

full paths      = cron mein recommended

flock           = overlapping jobs prevent karta hai
```

---

# 25. Final Flow

```text
Cron Scheduler
      ↓
Har Minute
      ↓
backup.sh run
      ↓
Timestamped ZIP create
      ↓
Backups count
      ↓
Latest 5 keep
      ↓
Older backups remove
      ↓
Output log file mein
```

---

# Recommended Classroom Cron Entry

```cron
* * * * * /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```

# Safer Version with `flock`

```cron
* * * * * flock -n /tmp/backup_rotation.lock /home/khalid/backup-project/backup.sh /home/khalid/backup-project/data /home/khalid/backup-project/backups >> /home/khalid/backup-project/backup-cron.log 2>&1
```
