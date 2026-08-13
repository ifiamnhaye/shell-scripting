# Bash File Descriptors aur Command Status — Roman Urdu Study Notes

## Table of Contents

- [1. Mukhtasar Taaruf](#1-mukhtasar-taaruf)
- [2. File Descriptor Kya Hota Hai?](#2-file-descriptor-kya-hota-hai)
- [3. Standard File Descriptors](#3-standard-file-descriptors)
- [4. File Descriptor Ke Examples](#4-file-descriptor-ke-examples)
- [5. Command Status Kya Hota Hai?](#5-command-status-kya-hota-hai)
- [6. File Descriptor vs Command Status](#6-file-descriptor-vs-command-status)
- [7. Ek Hi Number Ke Mukhtalif Meaning](#7-ek-hi-number-ke-mukhtalif-meaning)
- [8. Complete Script Example](#8-complete-script-example)
- [9. Common Mistakes](#9-common-mistakes)
- [10. Quick Reference](#10-quick-reference)
- [11. Practice Lab](#11-practice-lab)
- [12. Summary](#12-summary)

---

## 1. Mukhtasar Taaruf

File descriptor aur command status dono numbers use karte hain, lekin dono ka kaam bilkul mukhtalif hai:

```text
File descriptor = Data kahan travel karega?
Command status  = Command kis tarah complete hui?
```

- **File descriptor** kisi open input/output resource ko identify karta hai.
- **Command status** batata hai ke complete hone wali command successful hui ya fail.

---

## 2. File Descriptor Kya Hota Hai?

**File descriptor** ek chhota integer number hota hai jise process kisi open input/output resource ke reference ke taur par use karta hai.

Simple alfaaz mein:

> File descriptor ek numeric handle hai jo command ko batata hai ke input kahan se lena hai ya output kahan bhejna hai.

File descriptor khud file nahi hota. Yeh in resources ko refer kar sakta hai:

- Terminal
- Regular file
- Pipe
- Socket
- Koi doosra input/output resource

File descriptors running process ke andar us waqt tak available rehte hain jab tak unke resources open hon.

---

## 3. Standard File Descriptors

Har Bash command normally teen standard file descriptors ke saath start hoti hai:

| Number | Naam | Kaam |
|---:|---|---|
| `0` | stdin | Command ko input provide karta hai. |
| `1` | stdout | Command ka normal output bahar le jata hai. |
| `2` | stderr | Command ke error messages bahar le jata hai. |

Default flow:

```text
Keyboard ── stdin (0) ──> Command
Command  ── stdout (1) ─> Terminal
Command  ── stderr (2) ─> Terminal
```

**Stream** woh logical rasta hai jis ke zariye data flow karta hai. Stream koi folder nahi hoti.

---

## 4. File Descriptor Ke Examples

### 4.1 stdout Ko Redirect Karna

```bash
echo "Hello" 1> output.log
```

Explanation:

- `echo` normally stdout par likhta hai.
- `1` stdout ko identify karta hai.
- `>` output ko `output.log` mein redirect karta hai.

stdout default output stream hai, is liye `1` ko omit bhi kar sakte hain:

```bash
echo "Hello" > output.log
```

### 4.2 stderr Ko Redirect Karna

```bash
ls /missing 2> error.log
```

Explanation:

- `ls` `/missing` ko access nahi kar sakti.
- Error stderr par generate hota hai.
- `2>` stderr ko `error.log` mein bhejta hai.

### 4.3 `echo` Ka Message stderr Par Bhejna

```bash
echo "Error: file not found" >&2
```

`echo` normally stdout par likhta hai. `>&2` uske stdout ko stderr ki current destination par bhej deta hai.

Isay explicitly is tarah likh sakte hain:

```bash
echo "Error: file not found" 1>&2
```

Yeh dono same hain:

```bash
>&2
1>&2
```

Important: `&2` ka matlab `2` naam ki file nahi hai. Ampersand `&` Bash ko batata hai ke `2` ek **file descriptor** hai.

### 4.4 stdout aur stderr Ko Ek File Mein Bhejna

```bash
command > all.log 2>&1
```

Bash redirections ko left se right process karta hai:

1. `> all.log` stdout ko `all.log` mein bhejta hai.
2. `2>&1` stderr ko stdout ki current destination par bhejta hai.
3. Is liye stdout aur stderr dono `all.log` mein chale jate hain.

Bash mein iska short form bhi hai:

```bash
command &> all.log
```

### 4.5 Custom File Descriptor Use Karna

```bash
exec 3> custom.log
echo "Custom message" >&3
exec 3>&-
```

Explanation:

- `exec 3> custom.log` file descriptor `3` ko `custom.log` ke liye open karta hai.
- `>&3` message ko descriptor `3` ke zariye bhejta hai.
- `exec 3>&-` descriptor `3` ko close karta hai.

---

## 5. Command Status Kya Hota Hai?

**Command status**, jise **exit status** ya **return status** bhi kehte hain, woh number hai jo command complete hone par return karti hai.

Normal convention:

```text
0       = success
nonzero = failure, warning ya koi special result
```

Shell statuses normally `0` se `255` ki range mein represent hote hain.

### Last Status Check Karna

```bash
ls /missing
echo "$?"
```

`$?` mein sab se recently execute hone wali command ka status hota hai.

Failed `ls` command yeh status return kar sakti hai:

```text
2
```

Nonzero statuses ke exact meanings har command khud define karti hai.

### Script Ka Status Set Karna

```bash
exit 0
```

Yeh script ko band karke success report karta hai.

```bash
exit 1
```

Yeh script ko band karke general failure report karta hai.

### Status Ko Foran Save Karna

Har next command `$?` ko replace kar deti hai. Kisi aur command se pehle status save karein:

```bash
cp source.txt backup.txt
status=$?
echo "cp returned: $status"
```

---

## 6. File Descriptor vs Command Status

| Feature | File Descriptor | Command Status |
|---|---|---|
| Purpose | Input/output channel ko identify karta hai | Batata hai command kis tarah finish hui |
| Main question | Data kahan jana chahiye? | Command successful hui ya fail? |
| Common values | `0`, `1`, `2` aur custom descriptors | Normally `0` se `255` |
| Kis ke saath use hota hai? | Redirection operators | `$?`, `if`, `exit` aur `return` |
| Examples | `2> error.log`, `>&2` | `echo "$?"`, `exit 1` |
| Kab relevant hota hai? | Jab process ka resource open hota hai | Jab command complete hoti hai |
| `0` ka meaning | stdin | Successful completion |
| `1` ka meaning | stdout | Convention ke mutabiq nonzero result ya general failure |
| `2` ka meaning | stderr | Command ka define kiya hua nonzero result |

Numbers ek jaise nazar aa sakte hain, lekin dono systems ka aapas mein koi direct relation nahi hai.

---

## 7. Ek Hi Number Ke Mukhtalif Meaning

Yeh commands dekhein:

```bash
ls /missing 2> error.log
echo "$?"
```

Yahan number `2` do alag meanings ke saath aa sakta hai.

### Redirection Mein

```bash
2> error.log
```

Yahan `2` stderr ka **file descriptor** hai. Yeh sawal ka jawab deta hai:

> Error message kahan jana chahiye?

### Command Result Mein

```bash
echo "$?"
```

Agar yeh `2` print kare to woh `ls` ka return kiya hua **exit status** hai. Yeh sawal ka jawab deta hai:

> `ls` command kis tarah finish hui?

Exit status ka `2` hona sirf ittefaq hai; iska matlab stderr nahi hota.

Ek aur comparison:

```bash
exit 2
```

Yahan `2` command status hai.

```bash
echo "Error" >&2
```

Yahan `2` file descriptor hai.

---

## 8. Complete Script Example

```bash
#!/bin/bash

# Purpose: File copy karna aur errors handle karna.

source_file="${1:-}"
destination="${2:-}"

if [[ -z "$source_file" || -z "$destination" ]]; then
    echo "Usage: $0 SOURCE DESTINATION" >&2
    exit 1
fi

if cp -- "$source_file" "$destination" 2> error.log; then
    echo "Copy completed"
    exit 0
else
    status=$?
    echo "Copy failed with status: $status" >&2
    exit "$status"
fi
```

### Explanation

| Code | Meaning |
|---|---|
| `2> error.log` | `cp` ke error messages ko file descriptor `2` ke zariye `error.log` mein bhejta hai. |
| `if cp ...; then` | `cp` ke return kiye hue command status ko directly check karta hai. |
| `status=$?` | `cp` ka failure status foran save karta hai. |
| `>&2` | Custom error message ko stderr par bhejta hai. |
| `exit 0` | Script ko successful status ke saath band karta hai. |
| `exit "$status"` | Script ko `cp` ke return kiye hue failure status ke saath band karta hai. |

Is example mein file descriptors control karte hain ke **messages kahan jayen**, jab ke command statuses control karte hain ke **script agla faisla kya kare**.

---

## 9. Common Mistakes

### Mistake 1: `$?` Ko File Descriptor Samajhna

```bash
echo "$?"
```

`$?` previous command ka status hai. Yeh input/output channel nahi hai.

### Mistake 2: `2>` Ko Status 2 Samajhna

```bash
command 2> error.log
```

Yahan `2` stderr ko identify karta hai. Yeh redirection command ka status `2` set nahi karti.

### Mistake 3: `$?` Ko Der Se Check Karna

Incorrect:

```bash
cp source.txt backup.txt
echo "Copy attempted"
echo "$?"
```

Final `echo "$?"`, `cp` ka nahi balki pehli `echo` command ka status print karega.

Correct:

```bash
cp source.txt backup.txt
status=$?
echo "cp returned: $status"
```

### Mistake 4: Jab `if` Direct Check Kar Sakta Ho Tab `$?` Use Karna

Kam clear approach:

```bash
cp source.txt backup.txt

if [[ "$?" -eq 0 ]]; then
    echo "Copy completed"
fi
```

Preferred approach:

```bash
if cp source.txt backup.txt; then
    echo "Copy completed"
fi
```

### Mistake 5: `>&2` Ko `>2` Samajhna

```bash
echo "Error" >2
```

Yeh `2` naam ki file create ya overwrite karta hai.

```bash
echo "Error" >&2
```

Yeh message ko stderr ki current destination par bhejta hai.

### Mistake 6: Redirection Order Ko Ulta Karna

Yeh commands hamesha equivalent nahi hain:

```bash
command > all.log 2>&1
command 2>&1 > all.log
```

Pehli command mein dono streams `all.log` mein jati hain.

Doosri command mein stderr pehle stdout ki original destination ke saath connect hota hai, phir sirf stdout ko `all.log` mein bheja jata hai. Redirections left se right process hoti hain.

---

## 10. Quick Reference

### File Descriptors aur Redirection

| Syntax | Meaning |
|---|---|
| `0` | stdin |
| `1` | stdout |
| `2` | stderr |
| `> file` | stdout ko file mein bhej kar file overwrite karta hai. |
| `>> file` | stdout ko file ke end mein append karta hai. |
| `2> file` | stderr ko file mein bhej kar file overwrite karta hai. |
| `2>> file` | stderr ko file ke end mein append karta hai. |
| `>&2` | stdout ko stderr ki current destination par bhejta hai. |
| `2>&1` | stderr ko stdout ki current destination par bhejta hai. |
| `&> file` | stdout aur stderr dono ko ek file mein bhejta hai. |

### Command Status

| Syntax | Meaning |
|---|---|
| `$?` | Sab se recently complete hone wali command ka status |
| `0` | Success |
| Nonzero | Failure ya command ka define kiya hua doosra result |
| `exit N` | Script ko status `N` ke saath band karta hai |
| `return N` | Function ko status `N` ke saath band karta hai |
| `if command; then` | Command status `0` ho to `then` block chalata hai |
| `if ! command; then` | Command status nonzero ho to `then` block chalata hai |

---

## 11. Practice Lab

`fd_status_demo.sh` banayein jo:

1. Source path ko `$1` ke taur par accept kare.
2. `$1` missing ho to usage message stderr par bheje.
3. Source ko `/tmp/source-backup` mein copy karne ke liye `cp` use kare.
4. `cp` ke errors ko `error.log` mein bheje.
5. Copy successful ho to stdout par success message print kare.
6. Failure par `cp` ka status save aur print kare.
7. Success par `0`, aur failure par saved `cp` status ke saath exit kare.

Suggested tests:

```bash
bash fd_status_demo.sh
echo "$?"
```

```bash
bash fd_status_demo.sh missing.txt
status=$?
cat error.log
echo "Script status: $status"
```

```bash
touch report.txt
bash fd_status_demo.sh report.txt
echo "$?"
```

---

## 12. Summary

Yeh distinction yaad rakhein:

```text
File descriptor = Input ya output kahan travel karega
Command status  = Command successful hui ya kis tarah complete hui
```

Examples:

```bash
echo "Error" >&2
```

Yahan `2` file descriptor hai.

```bash
exit 2
```

Yahan `2` command status hai.

Final rule:

> File descriptors input aur output ko manage karte hain. Command statuses success ya failure report karte hain.

