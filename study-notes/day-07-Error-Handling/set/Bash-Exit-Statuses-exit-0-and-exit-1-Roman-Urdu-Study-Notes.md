# Bash Exit Statuses: `exit 0` aur `exit 1` — Roman Urdu Study Notes

## Table of Contents

- [Introduction](#introduction)
- [Basic Rule](#basic-rule)
- [`exit 0`: Success](#exit-0-success)
- [`exit 1`: Failure](#exit-1-failure)
- [`$?` se Status Check Karna](#se-status-check-karna)
- [Exit Statuses Kyun Important Hain?](#exit-statuses-kyun-important-hain)
- [Input Validation Example](#input-validation-example)
- [Help Request](#help-request)
- [Root Permission Example](#root-permission-example)
- [`exit` ke Baad Commands](#exit-ke-baad-commands)
- [Explicit `exit` ke Baghair Behavior](#explicit-exit-ke-baghair-behavior)
- [`exit` aur `return` ka Farq](#exit-aur-return-ka-farq)
- [Custom Exit Statuses](#custom-exit-statuses)
- [Common Mistakes](#common-mistakes)
- [Quick Reference](#quick-reference)
- [Key Lesson](#key-lesson)

## Introduction

Bash scripting mein `exit` puri script ko terminate karta hai aur operating system, parent shell, calling script, CI/CD pipeline, scheduler ya monitoring system ko ek status number return karta hai.

Syntax:

```bash
exit STATUS
```

Sab se zyada use hone wale do statuses hain:

```bash
exit 0
exit 1
```

## Basic Rule

| Exit status | General matlab |
|---:|---|
| `0` | Success |
| Non-zero | Failure ya koi doosri special condition |
| `1` | General failure |

Bash convention yeh hai:

```text
0 = success
1 = failure
```

## `exit 0`: Success

```bash
exit 0
```

Iska matlab hai:

> Script ko band karo aur report karo ke kaam successfully complete hua.

Example:

```bash
#!/bin/bash

echo "Backup completed successfully."
exit 0
```

Script run karke status check karein:

```bash
bash backup.sh
echo $?
```

Expected status:

```text
0
```

## `exit 1`: Failure

```bash
exit 1
```

Iska matlab hai:

> Script ko band karo aur general failure report karo.

Example:

```bash
#!/bin/bash

source_file="missing.txt"

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist." >&2
    exit 1
fi

echo "File exists."
exit 0
```

Agar file exist nahi karti, to script error display karti hai aur success section tak pohanchne se pehle status `1` ke saath exit ho jati hai.

## `$?` se Status Check Karna

```bash
echo $?
```

`$?` mein sab se recently complete hone wale foreground command, script ya pipeline ka exit status hota hai.

Status ko foran check karein:

```bash
bash backup.sh
echo $?
```

Kisi aur command ke run hone ke baad `$?` ki value badal jati hai. Yeh example misleading ho sakta hai:

```bash
bash backup.sh
echo "Script finished"
echo $?
```

Final status `backup.sh` ka nahi, balkeh `echo "Script finished"` ka hoga.

Agar status baad mein chahiye ho to usay variable mein save karein:

```bash
bash backup.sh
status=$?

echo "Backup status: $status"
```

## Exit Statuses Kyun Important Hain?

Automation exit status dekh kar faisla karti hai ke task successful hua ya fail.

`$?` use karne ka example:

```bash
bash backup.sh

if [[ "$?" -eq 0 ]]; then
    echo "The backup script succeeded."
else
    echo "The backup script failed."
fi
```

Cleaner approach mein script ko directly test karein:

```bash
if bash backup.sh; then
    echo "The backup script succeeded."
else
    echo "The backup script failed."
fi
```

Exit statuses in jagahon par use hote hain:

- Doosri Bash scripts
- Cron jobs
- Systemd services
- CI/CD pipelines
- Monitoring systems
- Deployment automation

## Input Validation Example

```bash
#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 NUMBER" >&2
    exit 1
fi

number="$1"

if [[ ! "$number" =~ ^[0-9]+$ ]]; then
    echo "Error: enter a non-negative whole number." >&2
    exit 1
fi

echo "Valid number: $number"
exit 0
```

### Input missing ho

```bash
bash number.sh
```

Result:

```text
Usage: number.sh NUMBER
Exit status: 1
```

### Valid input ho

```bash
bash number.sh 10
```

Result:

```text
Valid number: 10
Exit status: 0
```

## Help Request

User ke request karne par help display karna normally successful operation hai:

```bash
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 <directory>"
    exit 0
fi
```

User ne help mangi aur script ne help successfully provide kar di, is liye `exit 0` sahi hai.

Agar usage is liye display ho rahi ho ke required input missing hai, to failure report karein:

```bash
if [[ "$#" -ne 1 ]]; then
    echo "Error: one directory is required." >&2
    echo "Usage: $0 <directory>" >&2
    exit 1
fi
```

## Root Permission Example

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
    echo "Error: run this script with sudo." >&2
    exit 1
fi

echo "Root permission confirmed."

# Administrative commands go here.

exit 0
```

Sudo ke baghair:

```bash
bash admin.sh
```

Script status `1` ke saath exit hoti hai kyun ke uska EUID `0` nahi hai.

Sudo ke saath:

```bash
sudo bash admin.sh
```

Root check successful hota hai aur script status `0` ke saath complete ho sakti hai.

## `exit` ke Baad Commands

Executed `exit` ke baad likhe commands run nahi hote:

```bash
#!/bin/bash

echo "Before exit"
exit 1
echo "After exit"
```

Output:

```text
Before exit
```

`echo "After exit"` command kabhi execute nahi hoti.

## Explicit `exit` ke Baghair Behavior

Agar script explicit `exit` ke baghair end tak pohanch jaye, to normally last executed command ka status return karti hai.

```bash
#!/bin/bash

echo "Completed"
```

`echo` normally successful hota hai, is liye yeh script normally status `0` return karegi.

Explicit status intention ko clear banata hai:

```bash
exit 0
```

## `exit` aur `return` ka Farq

Puri script terminate karne ke liye `exit` use karein:

```bash
exit 1
```

Sirf current function se bahar aane ke liye `return` use karein:

```bash
check_file()
{
    if [[ ! -f "$1" ]]; then
        echo "File does not exist." >&2
        return 1
    fi

    echo "File exists."
    return 0
}
```

| Command | Asar |
|---|---|
| `exit 0` | Puri script ko successfully terminate karta hai |
| `exit 1` | Puri script ko failure ke saath terminate karta hai |
| `return 0` | Current function se successfully bahar aata hai |
| `return 1` | Current function se failure ke saath bahar aata hai |

Function ka status use karein:

```bash
if check_file "report.txt"; then
    echo "Continue processing."
else
    echo "Cannot continue." >&2
    exit 1
fi
```

## Custom Exit Statuses

Script mukhtalif problems ke liye alag non-zero statuses use kar sakti hai:

```bash
#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    echo "Error: one argument is required." >&2
    exit 2
fi

if [[ ! -d "$1" ]]; then
    echo "Error: directory does not exist." >&2
    exit 3
fi

echo "Directory is valid."
exit 0
```

| Status | Script mein define kiya gaya matlab |
|---:|---|
| `0` | Success |
| `1` | General error |
| `2` | Incorrect arguments |
| `3` | Directory exist nahi karti |

Custom meanings ko script ki help ya README mein document karna chahiye.

Bash statuses normally is range mein interpret kiye jate hain:

```text
0–255
```

Beginner scripts ke liye success par `0` aur general failure par `1` normally kafi hain.

## Common Mistakes

### Success ke baad failure report karna

Ghalat:

```bash
echo "Backup completed."
exit 1
```

Sahi:

```bash
echo "Backup completed."
exit 0
```

### Failure ke baad success report karna

Ghalat:

```bash
echo "Error: backup failed." >&2
exit 0
```

Sahi:

```bash
echo "Error: backup failed." >&2
exit 1
```

### Kisi aur command ke baad `$?` check karna

```bash
bash backup.sh
echo "Checking status"
echo $?
```

Displayed status pehle `echo` ka hoga, zaroori nahi ke `backup.sh` ka ho.

### Function ke andar ghalti se `exit` use karna

```bash
check_file()
{
    exit 1
}
```

Yeh puri script terminate kar dega. Agar sirf function ko rokna ho to `return 1` use karein.

## Quick Reference

| Expression | Roman Urdu mein matlab |
|---|---|
| `exit 0` | Script band karo aur success report karo |
| `exit 1` | Script band karo aur general failure report karo |
| `exit 2` | Custom non-zero status ke saath band karo |
| `$?` | Sab se recently complete hone wale command ka status |
| `status=$?` | Recent status ko variable mein save karo |
| `return 0` | Function se successfully bahar aao |
| `return 1` | Function se failure ke saath bahar aao |
| `>&2` | Message ko standard error par bhejo |
| `0–255` | Normal interpreted exit-status range |

## Key Lesson

```bash
exit 0
```

ka matlab hai:

> Script ko band karo aur success report karo.

```bash
exit 1
```

ka matlab hai:

> Script ko band karo aur failure report karo.

Previous command ya script ka result foran check karein:

```bash
echo $?
```
