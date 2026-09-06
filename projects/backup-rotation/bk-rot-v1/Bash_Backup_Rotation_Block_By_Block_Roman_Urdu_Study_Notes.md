# Bash Backup Rotation Script — Block-by-Block Roman Urdu Study Notes

## vim backup_rotation.sh

```bash
#!/bin/bash

function display_usage {
    echo "Usage: ./backup.sh <path to your source> <path to backup folder>"
}

if [ $# -ne 2 ]; then
    display_usage
    exit 1
fi

source_dir="$1"
backup_dir="$2"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

function create_backup {

    if zip -r "${backup_dir}/backup_${timestamp}.zip" "$source_dir"; then
        echo "Backup generated successfully for ${timestamp}"
    else
        echo "Backup failed"
        exit 1
    fi
}

function perform_rotation {

    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    if [ "${#backups[@]}" -gt 5 ]; then

        echo "Performing rotation. Keeping latest 5 backups."

        backups_to_remove=("${backups[@]:5}")

        echo "Backups to remove:"
        printf '%s\n' "${backups_to_remove[@]}"

        for backup in "${backups_to_remove[@]}"; do
            echo "Removing: $backup"
            rm -f -- "$backup"
        done

    else
        echo "Rotation not required. Total backups: ${#backups[@]}"
    fi
}

create_backup
perform_rotation
```

---

## 1. Shebang

```bash
#!/bin/bash
```

Ye Linux ko batata hai ke script ko **Bash interpreter** ke through run karna hai.

```text
/bin/bash = Bash interpreter
```

Simple yaad rakhein:

> Shebang batata hai ke script ko kis interpreter ke saath chalana hai.

---

## 2. Usage Function

```bash
function display_usage {
    echo "Usage: ./backup.sh <path to your source> <path to backup folder>"
}
```

Ye function user ko script chalane ka correct tareeqa dikhata hai.

Example:

```bash
./backup.sh ./data ./backups
```

Yahan:

```text
./data      = source directory
./backups   = backup directory
```

### Function kya hota hai?

Function commands ka reusable block hota hai.

Instead of baar baar same commands likhne ke, hum function define karke usko call kar sakte hain.

Example:

```bash
display_usage
```

---

## 3. Argument Validation

```bash
if [ $# -ne 2 ]; then
    display_usage
    exit 1
fi
```

Script ko exactly **2 arguments** chahiye.

```text
$1 = source directory
$2 = backup directory
$# = total number of arguments
```

### `$#`

```bash
$#
```

Matlab:

> User ne total kitne arguments diye?

Example:

```bash
./backup.sh ./data ./backups
```

to:

```text
$# = 2
```

### `-ne`

```bash
-ne
```

Matlab:

> not equal

So:

```bash
[ $# -ne 2 ]
```

ka matlab:

> Agar arguments ki total quantity 2 ke equal nahi hai.

Phir:

```bash
display_usage
exit 1
```

usage message show karega aur script stop ho jayegi.

### Exit Status

```text
exit 0 = success
exit 1 = error/failure
```

Flow:

```text
Arguments received
      ↓
Exactly 2?
 ┌────┴────┐
No        Yes
↓           ↓
Usage      Continue
↓
exit 1
```

---

## 4. Arguments ko Variables mein Store karna

```bash
source_dir="$1"
backup_dir="$2"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

Agar user chalaye:

```bash
./backup.sh ./data ./backups
```

to:

```text
source_dir = ./data
backup_dir = ./backups
```

Quotes use karna achhi practice hai, kyun ke paths mein spaces ho sakte hain.

---

## 5. Timestamp

```bash
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

`$(...)` ko **command substitution** kehte hain.

Matlab:

> Command run karo aur uska output variable mein save karo.

Example:

```bash
date '+%Y-%m-%d-%H-%M-%S'
```

Possible output:

```text
2026-09-02-11-30-45
```

Is se har backup ko unique naam milta hai.

Example:

```text
backup_2026-09-02-11-30-45.zip
backup_2026-09-02-11-35-10.zip
```

---

## 6. `create_backup` Function

```bash
function create_backup {

    if zip -r "${backup_dir}/backup_${timestamp}.zip" "$source_dir"; then
        echo "Backup generated successfully for ${timestamp}"
    else
        echo "Backup failed"
        exit 1
    fi
}
```

Is function ka purpose:

> Source directory ka ZIP backup create karna.

---

## 7. ZIP Command

```bash
zip -r "${backup_dir}/backup_${timestamp}.zip" "$source_dir"
```

### `zip`

ZIP archive create karta hai.

### `-r`

```bash
-r
```

Matlab:

> recursive

Agar source ek directory hai, to uske andar ki files, subdirectories aur unke andar ki files bhi ZIP mein include hongi.

Example:

```text
data/
├── file1.txt
├── file2.txt
└── logs/
    └── app.log
```

`-r` ki wajah se poora structure backup mein chala jayega.

---

## 8. Backup Filename

```bash
"${backup_dir}/backup_${timestamp}.zip"
```

Suppose:

```text
backup_dir = ./backups
timestamp  = 2026-09-02-11-30-45
```

Backup file banegi:

```text
./backups/backup_2026-09-02-11-30-45.zip
```

---

## 9. `zip` ko Directly `if` ke Andar Kyun Rakha?

```bash
if zip -r ...; then
```

Bash `zip` command ka exit status check karta hai.

```text
0     = success
non-0 = failure
```

Agar ZIP successful ho:

```bash
echo "Backup generated successfully for ${timestamp}"
```

run hoga.

Agar ZIP fail ho:

```bash
echo "Backup failed"
exit 1
```

run hoga.

Flow:

```text
zip command
    ↓
Successful?
 ┌──┴───┐
Yes     No
↓        ↓
Success Failure
message message
         ↓
       exit 1
```

Ye simple:

```bash
zip ...
echo "Backup successful"
```

se better hai, kyun ke simple `echo` ZIP fail hone par bhi success message dikha sakta hai.

---

## 10. `perform_rotation` Function

```bash
function perform_rotation {
```

Is function ka purpose:

> Latest 5 backups ko keep karna aur older backups ko remove karna.

---

## 11. Backups ko Array mein Load karna

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

### `ls -t`

```bash
ls -t
```

Files ko modification time ke hisaab se sort karta hai.

Order:

```text
newest
  ↓
older
  ↓
oldest
```

Example:

```text
backup_10.zip
backup_09.zip
backup_08.zip
backup_07.zip
backup_06.zip
backup_05.zip
```

### Matching Pattern

```bash
"${backup_dir}/backup_"*.zip
```

Sirf aisi ZIP files match hongi:

```text
backup_*.zip
```

Example:

```text
backup_2026-09-02-10-00-00.zip
backup_2026-09-02-11-00-00.zip
```

### `2>/dev/null`

```bash
2>/dev/null
```

Matlab:

> Error output ko hide kar do.

Linux standard streams:

```text
1 = stdout
2 = stderr
```

`/dev/null` ko simple analogy mein Linux ka dustbin samajh sakte hain.

Agar matching backup file na mile aur `ls` error de, to wo screen par show nahi hoga.

---

## 12. Bash Array

```bash
backups=(...)
```

Command ka output Bash array mein store hota hai.

Conceptually:

```text
backups[0] = newest backup
backups[1] = second newest backup
backups[2] = third newest backup
```

Important:

> Bash array indexing `0` se start hoti hai.

---

## 13. Backups ki Count Check karna

```bash
if [ "${#backups[@]}" -gt 5 ]; then
```

### `${#backups[@]}`

Matlab:

> Array mein total kitne elements hain?

Example:

```bash
backups=(a.zip b.zip c.zip d.zip e.zip f.zip g.zip)
```

Then:

```bash
echo "${#backups[@]}"
```

Output:

```text
7
```

### `-gt`

```bash
-gt
```

Matlab:

> greater than

So:

```bash
[ "${#backups[@]}" -gt 5 ]
```

ka matlab:

> Agar total backups 5 se zyada hain.

---

## 14. Latest 5 Backups Keep karna

Kyun ke `ls -t` newest backup pehle deta hai:

```text
backups[0] → KEEP
backups[1] → KEEP
backups[2] → KEEP
backups[3] → KEEP
backups[4] → KEEP

backups[5] → REMOVE
backups[6] → REMOVE
backups[7] → REMOVE
```

Yani first 5 elements latest backups hain.

---

## 15. Array Slicing

```bash
backups_to_remove=("${backups[@]:5}")
```

Ye rotation logic ki bohat important line hai.

### `${backups[@]}`

Matlab:

> Array ke tamam elements.

### `:5`

Matlab:

> Index 5 se start karo aur last tak jao.

So:

```bash
backups_to_remove=("${backups[@]:5}")
```

ka matlab:

> Latest 5 backups ko skip karo aur baqi older backups ko `backups_to_remove` array mein store karo.

---

## 16. Useful Array Slicing Examples

### Sab elements

```bash
"${backups[@]}"
```

### First 5 elements

```bash
"${backups[@]:0:5}"
```

### Index 5 se end tak

```bash
"${backups[@]:5}"
```

### Total elements ki count

```bash
"${#backups[@]}"
```

Easy memory:

```text
${array[@]}        = sab elements
${array[@]:0:5}    = first 5
${array[@]:5}      = index 5 se last
${#array[@]}       = total count
```

---

## 17. Backups to Remove Display karna

```bash
echo "Backups to remove:"
printf '%s\n' "${backups_to_remove[@]}"
```

`printf` har backup ko separate line par print karta hai.

Example:

```text
backup_03.zip
backup_02.zip
backup_01.zip
```

Ye:

```bash
echo "${backups_to_remove[@]}"
```

se zyada readable hai, kyun ke `echo` sab ko ek line par print kar sakta hai.

---

## 18. `for` Loop

```bash
for backup in "${backups_to_remove[@]}"; do
```

Ye har array element ko one-by-one process karta hai.

Example:

```text
1st iteration:
backup="backup_03.zip"

2nd iteration:
backup="backup_02.zip"

3rd iteration:
backup="backup_01.zip"
```

Simple:

> Array ke har old backup ko ek ek karke `backup` variable mein rakho.

---

## 19. Old Backup Remove karna

```bash
rm -f -- "$backup"
```

### `rm`

File remove karta hai.

### `-f`

```bash
-f
```

Force mode.

Confirmation prompt ke baghair file remove karta hai.

### `--`

```bash
--
```

Command options ka end show karta hai.

Iske baad jo bhi aaye usko filename/path samjha jata hai.

Ye unusual filenames ke liye useful hai.

Example:

```text
-test.zip
```

### `"$backup"`

Current loop item ko represent karta hai.

---

## 20. Jab Rotation Required na ho

```bash
else
    echo "Rotation not required. Total backups: ${#backups[@]}"
fi
```

Agar backups ki total quantity 5 ya us se kam ho to kuch delete nahi hoga.

Example:

```text
Rotation not required. Total backups: 4
```

---

## 21. Function Calls

```bash
create_backup
perform_rotation
```

Function define karna usko execute nahi karta.

### Definition

```bash
function create_backup {
    ...
}
```

### Call

```bash
create_backup
```

Script pehle new backup create karti hai.

Phir:

```bash
perform_rotation
```

rotation check karta hai.

Order:

```text
create_backup
      ↓
perform_rotation
```

---

# Complete Script Flow

```text
START
  ↓
Arguments check karo
  ↓
Exactly 2?
 ├── NO → Usage show karo → exit 1
 │
 └── YES
       ↓
source_dir set karo
backup_dir set karo
timestamp create karo
       ↓
create_backup
       ↓
ZIP successful?
 ├── NO → Backup failed → exit 1
 │
 └── YES
       ↓
perform_rotation
       ↓
Backups newest-first load karo
       ↓
Backups count karo
       ↓
5 se zyada?
 ├── NO → Rotation required nahi
 │
 └── YES
       ↓
Indexes 0–4 keep karo
       ↓
Index 5 se end tak select karo
       ↓
backups_to_remove mein store karo
       ↓
Old backups par loop chalao
       ↓
Har old backup delete karo
       ↓
END
```

---

# Variable Naming Recommendation

Lecture clarity ke liye:

```bash
backups_to_remove
```

ye naam:

```bash
old_backups
```

se zyada clear hai.

Kyun?

Kyun ke naam se hi pata chal raha hai ke in backups ke saath kya hona hai.

Aap students ko ye bhi dikha sakte hain:

```bash
backups_to_keep=("${backups[@]:0:5}")
backups_to_remove=("${backups[@]:5}")
```

Meaning:

```text
first 5        → backups_to_keep
index 5 onward → backups_to_remove
```

---

# Important Production Note

Learning version mein hum use kar rahe hain:

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

Classroom practice ke liye ye simple aur useful hai.

Lekin production scripts mein `ls` output parse karna ideal nahi hai, kyun ke filenames mein spaces ya unusual characters ho sakte hain.

Advanced production-safe approach:

```text
find
  ↓
modification time
  ↓
sort newest first
  ↓
mapfile
  ↓
Bash array
```

Yani learning progression:

```text
ls + array
    ↓
array slicing
    ↓
rotation
    ↓
find + sort + mapfile
```

---

# Quick Revision

```text
#!/bin/bash           = Bash interpreter use karo

$#                    = total arguments
$1                    = first argument
$2                    = second argument

-ne                   = not equal
-gt                   = greater than

$(command)            = command substitution

zip -r                = recursively ZIP create karo

ls -t                 = newest files first

2>/dev/null           = stderr hide karo

"${#array[@]}"        = total array elements
"${array[@]}"         = all array elements
"${array[@]:0:5}"     = first 5 elements
"${array[@]:5}"       = index 5 se end tak

for ... do ... done   = loop

rm -f -- "$file"      = file safely remove karo
```

---

# Suggested Lecture Delivery Order

1. Pehle problem explain karein: backup + rotation.
2. Required command-line arguments dikhayein.
3. `$1`, `$2`, aur `$#` explain karein.
4. Exactly 2 arguments validate karein.
5. Timestamp create karna explain karein.
6. `zip -r` explain karein.
7. `if` ke through command success/failure explain karein.
8. Backups ko array mein load karein.
9. `ls -t` explain karein.
10. Array elements ki count explain karein.
11. Bash array indexing explain karein.
12. Indexes `0–4` ko keep karna explain karein.
13. Index `5` se end tak slicing explain karein.
14. `for` loop se old backups process karein.
15. `rm` se delete karna explain karein.
16. Functions ko correct order mein call karein.
17. End mein `find + mapfile` production note dein.

---

# Final Concept

Script ko is short flow se yaad rakhein:

```text
Validate
   ↓
Backup
   ↓
Count
   ↓
Latest 5 Keep
   ↓
Older Backups Remove
```

Ye script in Bash topics ki strong practice hai:

- Arguments
- Variables
- Command substitution
- Functions
- Conditions
- Exit status
- Arrays
- Array slicing
- Loops
- ZIP backups
- Backup rotation
- File removal
