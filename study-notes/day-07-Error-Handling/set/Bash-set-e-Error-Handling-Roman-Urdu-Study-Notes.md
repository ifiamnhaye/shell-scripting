# Bash `set -e` Error Handling — Roman Urdu Study Notes

## Table of Contents

- [1. Basic Meaning](#1-basic-meaning)
- [2. `set -e` Ke Baghair](#2-set-e-ke-baghair)
- [3. `set -e` Ke Saath](#3-set-e-ke-saath)
- [4. Exit Status Ka Role](#4-exit-status-ka-role)
- [5. Important Exceptions](#5-important-exceptions)
- [6. Pipelines aur `pipefail`](#6-pipelines-aur-pipefail)
- [7. Strict Mode](#7-strict-mode)
- [8. Explicit Error Handling](#8-explicit-error-handling)
- [9. Functions aur Command Substitution](#9-functions-aur-command-substitution)
- [10. Enable aur Disable Karna](#10-enable-aur-disable-karna)
- [11. Complete Practical Script](#11-complete-practical-script)
- [12. Common Mistakes](#12-common-mistakes)
- [13. Practice Lab](#13-practice-lab)
- [14. Quick Reference](#14-quick-reference)
- [15. Final Summary](#15-final-summary)

---

## 1. Basic Meaning

```bash
set -e
```

`set -e` ko aam tor par **exit on error** kehte hain.

Simple Roman Urdu meaning:

> Agar script ki koi unhandled command nonzero status ke saath fail ho to script ko aage chalane ke bajaye exit kar do.

Basic example:

```bash
#!/bin/bash

set -e

echo "Script started"
cp missing.txt backup.txt
echo "Script completed"
```

Agar `missing.txt` available nahi hai to `cp` fail hogi. `set -e` ki wajah se script us point par band ho jayegi aur `Script completed` print nahi hoga.

Important:

> `set -e` ek safety option hai, lekin complete error-handling system nahi hai.

---

## 2. `set -e` Ke Baghair

```bash
#!/bin/bash

echo "Before cp"
cp missing.txt backup.txt
echo "After cp"
```

Agar `cp` fail ho, Bash normally aglay command par continue kar sakti hai.

```text
Before cp
cp: cannot stat 'missing.txt': No such file or directory
After cp
```

Is se false-success impression mil sakta hai, kyun ke important operation fail hone ke bawajood script aage chal rahi hai.

---

## 3. `set -e` Ke Saath

```bash
#!/bin/bash

set -e

echo "Before cp"
cp missing.txt backup.txt
echo "After cp"
```

Possible output:

```text
Before cp
cp: cannot stat 'missing.txt': No such file or directory
```

`After cp` print nahi hota.

```text
Command successful -> script continue
Command failed     -> set -e exit karwa sakta hai
```

---

## 4. Exit Status Ka Role

Har command complete hone par ek status return karti hai.

| Status | General Meaning |
|---:|---|
| `0` | Success |
| Nonzero | Failure ya command-defined special result |

Example:

```bash
ls /etc/passwd
echo "$?"
```

Successful `ls` normally status `0` return karti hai.

```bash
ls /missing-file
echo "$?"
```

Failed command nonzero status return karti hai. Exact nonzero value command khud define karti hai.

`$?` ko foran check ya save karein, kyun ke har next command usay replace kar deti hai:

```bash
cp source.txt backup.txt
status=$?
echo "cp status: $status"
```

---

## 5. Important Exceptions

`set -e` ka matlab yeh nahi ke **har nonzero status** par Bash lazmi exit karegi. Kuch contexts mein failure control-flow ka hissa hoti hai.

### Failure Inside `if`

```bash
if cp missing.txt backup.txt; then
    echo "Copy completed"
else
    echo "Copy failed" >&2
fi
```

Yahan `if` command status ko check kar raha hai, is liye failure par `else` block chal sakta hai.

### Failure with `!`

```bash
if ! mkdir new_directory; then
    echo "Directory could not be created" >&2
fi
```

`!` result ko reverse karta hai aur failure explicitly condition mein handle hoti hai.

### Failure with `||`

```bash
mkdir new_directory || echo "Directory creation failed" >&2
```

Pehli command ki failure OR list ka hissa hai, is liye right-side command chal sakti hai.

### Failure with `&&`

```bash
mkdir new_directory && echo "Directory created"
```

Pehli command fail ho to second command nahi chalegi. AND/OR lists mein `set -e` ka behavior standalone failure se different ho sakta hai.

### Loop Conditions

`while` aur `until` ki condition mein nonzero status loop decision ka hissa hota hai, is liye woh zaroori nahi ke script exit karwaye.

Core lesson:

> `set -e` context-sensitive hai. Critical commands ke liye explicit `if` handling zyada clear hoti hai.

---

## 6. Pipelines aur `pipefail`

```bash
grep "ERROR" missing.log | wc -l
```

Normally pipeline ka status last command se milta hai. Agar `grep` fail ho lekin `wc` successful ho jaye to pipeline status `0` ho sakta hai. `set -e` earlier failure miss kar sakta hai.

Enable `pipefail`:

```bash
set -o pipefail
```

Example:

```bash
#!/bin/bash

set -e
set -o pipefail

grep "ERROR" missing.log | wc -l
echo "Pipeline completed"
```

Agar `grep` input file open nahi kar sakti to pipeline nonzero status return karegi aur final `echo` execute nahi hoga.

### `grep` Ka Special Case

`grep` status `1` return karta hai jab koi match na mile. Yeh nonzero hai, lekin kuch workflows mein expected result hota hai.

```bash
if grep -q "ERROR" application.log; then
    echo "Errors found"
else
    status=$?

    if [[ "$status" -eq 1 ]]; then
        echo "No errors found"
    else
        echo "Error: grep could not process the file" >&2
        exit "$status"
    fi
fi
```

---

## 7. Strict Mode

Common Bash safety combination:

```bash
set -euo pipefail
```

| Option | Purpose |
|---|---|
| `-e` | Unhandled command failure par exit behavior enable karta hai. |
| `-u` | Unset variable use hone par error deta hai. |
| `-o pipefail` | Pipeline ke earlier failures expose karta hai. |

Optional error tracing:

```bash
set -Eeuo pipefail
```

Capital `-E` `ERR` trap ki inheritance ko functions, command substitutions, aur subshell contexts mein improve karta hai.

```bash
#!/bin/bash

set -Eeuo pipefail

trap 'echo "Error on line $LINENO" >&2' ERR

source_file="${1:-}"

if [[ -z "$source_file" ]]; then
    echo "Usage: $0 SOURCE_FILE" >&2
    exit 1
fi

cp -- "$source_file" backup.txt
echo "Backup completed"
```

Strict mode ke saath expected nonzero results ko explicitly handle karna zaroori hota hai.

---

## 8. Explicit Error Handling

Sirf automatic exit:

```bash
set -e
cp -- "$source_file" "$destination"
```

Clear handling:

```bash
if ! cp -- "$source_file" "$destination"; then
    echo "Error: backup failed" >&2
    exit 1
fi
```

Explicit handling ke benefits:

- User ko clear message milta hai.
- Failure ka context samajh aata hai.
- Cleanup, retry, ya recovery add ki ja sakti hai.
- Custom exit status use kiya ja sakta hai.

Original command status preserve karna ho to:

```bash
if cp -- "$source_file" "$destination"; then
    echo "Backup completed"
else
    status=$?
    echo "Error: backup failed with status $status" >&2
    exit "$status"
fi
```

`if ! command` ke `then` block mein `$?` negated result ko reflect kar sakta hai. Original failure status chahiye to `if command; then ... else ... fi` pattern clearer hai.

Final principle:

> `set -e` safety net hai; explicit `if/else` clear error handling hai.

---

## 9. Functions aur Command Substitution

Functions, command substitutions, subshells, aur conditional contexts mein `set -e` ka behavior subtle ho sakta hai.

### Function Ko Clear Status Return Karwana

```bash
create_backup()
{
    if ! cp missing.txt backup.txt; then
        echo "Error: backup copy failed" >&2
        return 1
    fi

    echo "Backup function completed"
}
```

Function ke andar failure explicitly handle karke `return 1` use ki gayi hai.

### Command Substitution

```bash
result=$(some_command)
```

Critical failure ke liye sirf `set -e` par depend na karein:

```bash
if ! result=$(some_command); then
    echo "Error: command substitution failed" >&2
    exit 1
fi
```

---

## 10. Enable aur Disable Karna

Enable:

```bash
set -e
```

Disable:

```bash
set +e
```

Dobara enable:

```bash
set -e
```

Example:

```bash
set +e
some_command_that_may_fail
status=$?
set -e
```

Temporary disable ke bajaye explicit conditional aksar zyada readable hoti hai:

```bash
if some_command_that_may_fail; then
    echo "Command succeeded"
else
    status=$?
    echo "Command returned: $status" >&2
fi
```

---

## 11. Complete Practical Script

```bash
#!/bin/bash

set -Eeuo pipefail

trap 'echo "Unexpected error on line $LINENO" >&2' ERR

source_file="${1:-}"
destination="${2:-}"

if [[ -z "$source_file" || -z "$destination" ]]; then
    echo "Usage: $0 SOURCE DESTINATION" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist: $source_file" >&2
    exit 1
fi

if cp -- "$source_file" "$destination"; then
    echo "Backup completed: $source_file -> $destination"
else
    status=$?
    echo "Error: backup failed with status $status" >&2
    exit "$status"
fi

exit 0
```

### Script Flow

1. Strict safety options enable hoti hain.
2. Unexpected error par `ERR` trap line number show karta hai.
3. Command-line arguments validate hote hain.
4. Source regular file validate hoti hai.
5. `cp` ka result direct `if` check karta hai.
6. Success stdout par aur failure stderr par jati hai.
7. Script accurate status return karti hai.

Syntax check:

```bash
bash -n safe_backup.sh
```

Debug run:

```bash
bash -x safe_backup.sh source.txt backup.txt
```

---

## 12. Common Mistakes

### Mistake 1: Samajhna Ke Har Failure Par Exit Hogi

`set -e` context-sensitive hai. `if`, `!`, `&&`, `||`, loop conditions, aur pipelines mein important exceptions hoti hain.

### Mistake 2: Complete Error Handling Samajhna

`set -e` descriptive error message, cleanup, retry, ya rollback automatically provide nahi karta.

### Mistake 3: `pipefail` Bhool Jana

```bash
set -e
command1 | command2
```

Earlier pipeline failure hide ho sakti hai. Zaroorat ho to `set -o pipefail` use karein.

### Mistake 4: Expected Nonzero Result Ko Unexpected Failure Samajhna

`grep` status `1` “no match” ke liye return karta hai. Kuch workflows mein yeh expected result hota hai.

### Mistake 5: Error Context Na Dena

Automatic exit user ko yeh nahi batati ke script kya kar rahi thi. Critical operations ke liye descriptive stderr messages use karein.

### Mistake 6: Cleanup Bhool Jana

Temporary resources ke cleanup ke liye `trap` useful hai:

```bash
temp_file=$(mktemp)
trap 'rm -f -- "$temp_file"' EXIT
```

---

## 13. Practice Lab

Create `set_e_demo.sh` jo:

1. `set -Eeuo pipefail` use kare.
2. `ERR` trap se failed line number stderr par print kare.
3. `$1` se source filename receive kare.
4. Missing argument aur file ko validate kare.
5. File ke andar `ERROR` search kare.
6. No match ko expected result ke taur par handle kare.
7. Real `grep` error ko failure ke taur par handle kare.
8. Success par `exit 0` return kare.

### Suggested Solution

```bash
#!/bin/bash

set -Eeuo pipefail

trap 'echo "Unexpected error on line $LINENO" >&2' ERR

source_file="${1:-}"

if [[ -z "$source_file" ]]; then
    echo "Usage: $0 SOURCE_FILE" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist: $source_file" >&2
    exit 1
fi

if grep -q "ERROR" "$source_file"; then
    echo "ERROR entry found"
else
    status=$?

    if [[ "$status" -eq 1 ]]; then
        echo "No ERROR entry found"
    else
        echo "Error: grep failed with status $status" >&2
        exit "$status"
    fi
fi

exit 0
```

Test data:

```bash
echo "INFO: application started" > application.log
bash set_e_demo.sh application.log
```

Add a match:

```bash
echo "ERROR: database unavailable" >> application.log
bash set_e_demo.sh application.log
```

Test missing file:

```bash
bash set_e_demo.sh missing.log
echo "$?"
```

---

## 14. Quick Reference

| Syntax | Meaning |
|---|---|
| `set -e` | Unhandled failure par exit behavior enable karta hai. |
| `set +e` | `-e` disable karta hai. |
| `set -u` | Unset variable ko error banata hai. |
| `set -o pipefail` | Pipeline ke earlier failures expose karta hai. |
| `set -E` | `ERR` trap inheritance improve karta hai. |
| `set -Eeuo pipefail` | Common strict safety combination hai. |
| `$?` | Previous command ka status hai. |
| `exit N` | Script ko status `N` ke saath band karta hai. |
| `return N` | Function ko status `N` ke saath end karta hai. |
| `if command; then` | Status `0` par `then` block chalata hai. |
| `if ! command; then` | Nonzero status par `then` block chalata hai. |

---

## 15. Final Summary

```bash
set -e
```

Practical Roman Urdu meaning:

> Agar koi unhandled command fail ho to script ko aage chalane ke bajaye exit kar do.

Lekin yaad rakhein:

- Har nonzero result par exit guaranteed nahi hoti.
- Behavior command ke context par depend karta hai.
- Pipelines ke liye aksar `pipefail` chahiye.
- Expected failures ko explicitly handle karna chahiye.
- Clear error messages stderr par bhejne chahiye.
- Cleanup ke liye `trap` useful hai.

Recommended mindset:

```text
set -e            = safety net
explicit if/else = clear error handling
```

Common starting point:

```bash
#!/bin/bash

set -Eeuo pipefail
```

Final rule:

> `set -e` par akelay depend na karein. Critical commands ko validate karein, clear errors dein, aur accurate exit statuses return karein.

