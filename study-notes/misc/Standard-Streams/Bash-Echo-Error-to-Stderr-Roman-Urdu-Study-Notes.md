# Bash `echo ... >&2` — Roman Urdu Study Notes

## Table of Contents

- [1. Command](#1-command)
- [2. Seedha Matlab](#2-seedha-matlab)
- [3. Command Ke Har Hissay Ki Explanation](#3-command-ke-har-hissay-ki-explanation)
- [4. `>&2` Kaise Kaam Karta Hai?](#4-2-kaise-kaam-karta-hai)
- [5. Standard Streams](#5-standard-streams)
- [6. Terminal Par Farq Kyun Nazar Nahi Aata?](#6-terminal-par-farq-kyun-nazar-nahi-aata)
- [7. stdout Aur stderr Ko Alag Save Karna](#7-stdout-aur-stderr-ko-alag-save-karna)
- [8. Complete Script Example](#8-complete-script-example)
- [9. `>&2`, `2>`, `2>>` Aur `&>` Ka Farq](#9-2-2-2-aur-ka-farq)
- [10. Common Mistakes](#10-common-mistakes)
- [11. Practice Lab](#11-practice-lab)
- [12. Quick Summary](#12-quick-summary)

---

## 1. Command

```bash
echo "Error: source file does not exist." >&2
```

Yeh command error message ko normal output ke bajaye **standard error (`stderr`)** par bhejti hai.

---

## 2. Seedha Matlab

```text
Error message ko error-output stream, yani stderr, par bhejo.
```

`echo` normally apna text stdout par bhejta hai. `>&2` uske stdout ko stderr ki current destination par redirect kar deta hai.

---

## 3. Command Ke Har Hissay Ki Explanation

| Hissa | Naam | Kya Karta Hai? |
|---|---|---|
| `echo` | Output command | Diya gaya text output karta hai. |
| `"Error: source file does not exist."` | Message | User ko batata hai ke source file maujood nahi hai. |
| `>` | Redirection operator | Output ka rasta badalta hai. |
| `&2` | File descriptor reference | File number `2` yani stderr ki current destination ko refer karta hai. |
| `>&2` | Complete redirection | stdout (`1`) ko stderr (`2`) ki destination par bhejta hai. |

---

## 4. `>&2` Kaise Kaam Karta Hai?

`echo` ka default output stdout, yani file descriptor `1`, hota hai.

```bash
echo "Hello"
```

Is command mein `Hello` stdout par jata hai.

Error command:

```bash
echo "Error: source file does not exist." >&2
```

Is mein `>&2` ka matlab hai:

```text
File descriptor 1 ko file descriptor 2 ki current destination par bhejo.
```

Isay explicitly is tarah bhi likh sakte hain:

```bash
echo "Error: source file does not exist." 1>&2
```

Yeh dono same hain:

```bash
>&2
1>&2
```

Important: `&2` ka matlab `2` naam ki file nahi hai. Ampersand `&` Bash ko batata hai ke `2` ek **file descriptor** hai.

---

## 5. Standard Streams

Bash command ke paas teen standard streams hoti hain:

| Number | Stream | Roman Urdu Meaning |
|---:|---|---|
| `0` | stdin | Input command tak jane ka logical rasta |
| `1` | stdout | Normal output bahar jane ka logical rasta |
| `2` | stderr | Error messages bahar jane ka logical rasta |

Stream koi folder nahi hoti. Stream data ke behne ka logical rasta hoti hai—bilkul pipe ki tarah—jo input ya output ko ek jagah se doosri jagah le jati hai.

---

## 6. Terminal Par Farq Kyun Nazar Nahi Aata?

Normally stdout aur stderr dono terminal se connected hote hain.

Normal output:

```bash
echo "Backup completed"
```

Error output:

```bash
echo "Error: backup failed" >&2
```

Dono messages terminal par dikhai denge. Isi liye zahiri tor par farq nazar nahi aata.

Asal farq tab samajh aata hai jab streams ko redirect kiya jaye.

---

## 7. stdout Aur stderr Ko Alag Save Karna

Example script:

```bash
echo "Backup started"
echo "Error: source file does not exist." >&2
```

Sirf stdout save karein:

```bash
bash script.sh > output.log
```

Natija:

- `Backup started` → `output.log`
- Error message → terminal

Sirf stderr save karein:

```bash
bash script.sh 2> error.log
```

Natija:

- Normal message → terminal
- Error message → `error.log`

Dono ko alag files mein save karein:

```bash
bash script.sh > output.log 2> error.log
```

Natija:

| Output | Destination |
|---|---|
| Normal messages | `output.log` |
| Error messages | `error.log` |

---

## 8. Complete Script Example

```bash
#!/bin/bash

# Purpose: Source file ko validate karna.

source_file="${1:-}"

if [[ -z "$source_file" ]]; then
    echo "Usage: $0 SOURCE_FILE" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist: $source_file" >&2
    exit 1
fi

echo "Source file exists: $source_file"
exit 0
```

### Script Ka Flow

1. `${1:-}` pehla argument leta hai. Argument na ho to empty value use hoti hai.
2. `[[ -z "$source_file" ]]` check karta hai ke filename diya gaya hai ya nahi.
3. Usage error stderr par bheja jata hai.
4. `[[ ! -f "$source_file" ]]` check karta hai ke regular file maujood nahi hai.
5. Missing-file message stderr par jata hai.
6. `exit 1` failure report karta hai.
7. Agar file maujood ho to success message stdout par jata hai.
8. `exit 0` successful completion report karta hai.

### Script Chalana

```bash
bash check_source.sh report.txt
```

Errors ko file mein save karna:

```bash
bash check_source.sh missing.txt 2> error.log
```

Error dekhna:

```bash
cat error.log
```

---

## 9. `>&2`, `2>`, `2>>` Aur `&>` Ka Farq

| Syntax | Kya Karta Hai? | Example Ka Natija |
|---|---|---|
| `>&2` | stdout ko stderr ki destination par bhejta hai | `echo "Error" >&2` error stream par message bhejta hai. |
| `2> file` | stderr ko file mein bhejta hai aur file overwrite karta hai | `cmd 2> error.log` naya error log banata hai. |
| `2>> file` | stderr ko file ke end mein add karta hai | `cmd 2>> error.log` purana content preserve karta hai. |
| `> file` | Sirf stdout ko file mein bhejta hai | `cmd > output.log` normal output save karta hai. |
| `&> file` | stdout aur stderr dono file mein bhejta hai | `cmd &> all.log` dono streams save karta hai. |
| `> file 2>&1` | Pehle stdout file mein, phir stderr ko stdout ki destination par | Dono streams `file` mein jati hain. |

---

## 10. Common Mistakes

### Mistake 1: `>2` Likhna

```bash
echo "Error" >2
```

Yeh stderr par redirect nahi karta. Yeh output ko `2` naam ki file mein save karta hai.

Correct:

```bash
echo "Error" >&2
```

### Mistake 2: `&>2` Ko `>&2` Samajhna

```bash
echo "Error" &>2
```

Yeh stdout aur stderr dono ko `2` naam ki file mein bhejta hai.

Lekin:

```bash
echo "Error" >&2
```

Yeh `echo` ka stdout stderr par bhejta hai.

### Mistake 3: Error Message stdout Par Bhejna

```bash
echo "Error: file missing"
```

Yeh message stdout par jata hai. Script chal sakti hai, lekin normal aur error output ko baad mein alag karna mushkil ho jata hai.

Behtar:

```bash
echo "Error: file missing" >&2
```

### Mistake 4: Error Ke Baad Success Status Dena

```bash
echo "Error: file missing" >&2
exit 0
```

`exit 0` success ko show karta hai. Error ke liye nonzero status use karein:

```bash
echo "Error: file missing" >&2
exit 1
```

---

## 11. Practice Lab

### Task

`validate_file.sh` banayein jo:

1. Pehla command-line argument filename ke taur par le.
2. Argument missing ho to usage message stderr par bheje.
3. File missing ho to error message stderr par bheje.
4. File available ho to success message stdout par bheje.
5. Failure par `exit 1` aur success par `exit 0` use kare.

### Test Commands

```bash
bash validate_file.sh
echo "$?"
```

```bash
bash validate_file.sh missing.txt 2> error.log
status=$?
cat error.log
echo "$status"
```

```bash
touch report.txt
bash validate_file.sh report.txt > output.log
cat output.log
```

Important: `$?` ko us command ke foran baad check ya variable mein save karein jiska status chahiye. Kisi doosri command ke baad `$?` change ho jata hai.

---

## 12. Quick Summary

```bash
echo "Error: source file does not exist." >&2
```

Iska simple meaning:

> Is message ko normal output nahi, balki error output samajh kar stderr par bhejo.

Yaad rakhne ka rule:

```text
1 = stdout = normal output
2 = stderr = error output
>&2 = stdout ko stderr ki destination par bhejo
```

Error handling ka common pattern:

```bash
source_file="abc.txt"
if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist." >&2
    exit 1
fi
```

[For Explanation Click here in Urdu](md/Bash-Source-File-Validation-Roman-Urdu-Study-Notes.md)

[For Explanation Click here](md/Bash-Source-File-Validation-Study-Notes.md)
