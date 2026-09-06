# Bash Backup Rotation Script — Code-by-Code Study Notes

## backup_rotation.sh

```bash
#!/bin/bash

# -----------------------------------
# Display usage
# -----------------------------------

function display_usage {

    echo "Usage: $0 <source_directory> <backup_directory> [keep_backups]"
    echo
    echo "Example:"
    echo "  $0 ./data ./backups"
    echo "  $0 ./data ./backups 10"
}


# -----------------------------------
# Validate number of arguments
# -----------------------------------

if [[ $# -lt 2 || $# -gt 3 ]]; then

    display_usage
    exit 1
fi


# -----------------------------------
# Variables
# -----------------------------------

source_dir="$1"
backup_dir="$2"

# If third argument is not provided,
# keep 5 backups by default
keep_backups="${3:-5}"

timestamp=$(date '+%Y-%m-%d-%H-%M-%S')


# -----------------------------------
# Validate source directory
# -----------------------------------

if [[ ! -d "$source_dir" ]]; then

    echo "Error: Source directory does not exist:"
    echo "$source_dir"

    exit 1
fi


# -----------------------------------
# Validate keep_backups
# -----------------------------------

if ! [[ "$keep_backups" =~ ^[1-9][0-9]*$ ]]; then

    echo "Error: keep_backups must be a positive integer."
    echo "Example: 5, 10, 15"

    exit 1
fi


# -----------------------------------
# Check zip command
# -----------------------------------

if ! command -v zip >/dev/null 2>&1; then

    echo "Error: zip command is not installed."
    echo "Install it first and run the script again."

    exit 1
fi


# -----------------------------------
# Create backup directory if needed
# -----------------------------------

mkdir -p -- "$backup_dir"


# -----------------------------------
# Create backup function
# -----------------------------------

function create_backup {

    backup_file="${backup_dir}/backup_${timestamp}.zip"

    echo "Creating backup..."
    echo "Source: $source_dir"
    echo "Destination: $backup_file"

    if zip -rq -- "$backup_file" "$source_dir"; then

        echo "Backup generated successfully."
        echo "Backup file: $backup_file"

    else

        echo "Backup failed."
        exit 1
    fi
}


# -----------------------------------
# Backup rotation function
# -----------------------------------

function perform_rotation {

    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    echo
    echo "Total backups: ${#backups[@]}"
    echo "Backups to keep: $keep_backups"

    if [[ ${#backups[@]} -gt $keep_backups ]]; then

        echo
        echo "Performing backup rotation..."

        # Latest backups to keep
        backups_to_keep=("${backups[@]:0:$keep_backups}")

        # Older backups to remove
        backups_to_remove=("${backups[@]:$keep_backups}")

        echo
        echo "Backups being kept:"
        printf '%s\n' "${backups_to_keep[@]}"

        echo
        echo "Backups to remove:"
        printf '%s\n' "${backups_to_remove[@]}"

        echo

        for backup in "${backups_to_remove[@]}"; do

            echo "Removing: $backup"

            rm -f -- "$backup"

        done

        echo
        echo "Backup rotation completed."

    else

        echo "Rotation not required."
    fi
}


# -----------------------------------
# Main
# -----------------------------------

create_backup
perform_rotation
```

---

# 1. Shebang

```bash
#!/bin/bash
```

Roman Urdu:

> Linux ko batata hai ke is script ko Bash interpreter ke through run karna hai.

```text
/bin/bash = Bash interpreter
```

---

# 2. `display_usage` Function

```bash
function display_usage {

    echo "Usage: $0 <source_directory> <backup_directory> [keep_backups]"
    echo
    echo "Example:"
    echo "  $0 ./data ./backups"
    echo "  $0 ./data ./backups 10"
}
```

Is function ka kaam user ko batana hai ke script ko kis syntax ke saath run karna hai.

### `$0`

```bash
$0
```

Current script ka naam deta hai.

Agar script ka naam:

```text
backup.sh
```

ho to:

```bash
echo "$0"
```

kuch aisa output de sakta hai:

```text
./backup.sh
```

### `[keep_backups]`

Square brackets documentation mein aam tor par **optional argument** show karte hain.

Yani user:

```bash
./backup.sh ./data ./backups
```

bhi chala sakta hai.

Aur:

```bash
./backup.sh ./data ./backups 10
```

bhi.

---

# 3. Argument Count Validation

```bash
if [[ $# -lt 2 || $# -gt 3 ]]; then

    display_usage
    exit 1
fi
```

### `$#`

```bash
$#
```

Total arguments ki quantity deta hai.

Example:

```bash
./backup.sh ./data ./backups 10
```

to:

```text
$# = 3
```

### `-lt`

```bash
-lt
```

means:

> less than

### `-gt`

```bash
-gt
```

means:

> greater than

### `||`

```bash
||
```

means:

> OR

So:

```bash
[[ $# -lt 2 || $# -gt 3 ]]
```

ka matlab:

> Agar arguments 2 se kam **ya** 3 se zyada hain to input invalid hai.

Valid cases:

```text
2 arguments ✅
3 arguments ✅
```

Invalid:

```text
0 arguments ❌
1 argument  ❌
4+ arguments ❌
```

### `exit 1`

```bash
exit 1
```

Script ko failure status ke saath stop karta hai.

---

# 4. Positional Arguments ko Variables mein Store karna

```bash
source_dir="$1"
backup_dir="$2"
```

Example:

```bash
./backup.sh ./data ./backups 10
```

Then:

```text
$1 = ./data
$2 = ./backups
$3 = 10
```

So:

```bash
source_dir="$1"
```

becomes:

```text
source_dir=./data
```

Aur:

```bash
backup_dir="$2"
```

becomes:

```text
backup_dir=./backups
```

Quotes use karna achhi practice hai:

```bash
"$1"
"$2"
```

kyun ke paths mein spaces ho sakte hain.

---

# 5. Optional Third Argument with Default Value

```bash
keep_backups="${3:-5}"
```

Ye script ka bohat useful concept hai.

### `${3:-5}`

Matlab:

> Agar `$3` diya gaya hai aur empty nahi hai to usko use karo. Warna default `5` use karo.

Example 1:

```bash
./backup.sh ./data ./backups
```

Then:

```text
$3 = missing
keep_backups = 5
```

Example 2:

```bash
./backup.sh ./data ./backups 10
```

Then:

```text
$3 = 10
keep_backups = 10
```

Easy formula:

```text
${variable:-default}
```

---

# 6. Timestamp

```bash
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

### `$(...)`

Command substitution.

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

Then:

```text
timestamp=2026-09-02-11-30-45
```

Backup filename ban sakta hai:

```text
backup_2026-09-02-11-30-45.zip
```

---

# 7. Source Directory Validation

```bash
if [[ ! -d "$source_dir" ]]; then
```

### `-d`

Check karta hai:

> Kya given path existing directory hai?

### `!`

Means:

> NOT

So:

```bash
[[ ! -d "$source_dir" ]]
```

ka matlab:

> Agar source directory exist nahi karti to error show karo.

Error block:

```bash
echo "Error: Source directory does not exist:"
echo "$source_dir"
exit 1
```

Ye isliye useful hai taake invalid source ke saath ZIP command unnecessarily run na ho.

---

# 8. `keep_backups` Validation

```bash
if ! [[ "$keep_backups" =~ ^[1-9][0-9]*$ ]]; then
```

Ye check karta hai ke retention value valid positive integer hai.

### `=~`

Bash regex matching operator.

### Regex

```text
^[1-9][0-9]*$
```

Breakdown:

```text
^        = string ka start
[1-9]    = first digit 1 se 9
[0-9]*   = uske baad zero ya zyada digits
$        = string ka end
```

Valid:

```text
1
5
10
25
100
```

Invalid:

```text
0
-5
abc
5.5
```

Agar invalid value ho:

```bash
echo "Error: keep_backups must be a positive integer."
exit 1
```

---

# 9. Check Whether `zip` Exists

```bash
if ! command -v zip >/dev/null 2>&1; then
```

### `command -v zip`

Check karta hai ke `zip` command available hai ya nahi.

Manual:

```bash
command -v zip
```

Possible output:

```text
/usr/bin/zip
```

### `>/dev/null`

Standard output hide kar deta hai.

### `2>&1`

Standard error ko bhi stdout wali destination par bhej deta hai.

So:

```bash
>/dev/null 2>&1
```

ka matlab:

> Normal output aur error dono hide kar do.

Humein sirf command ka success/failure chahiye.

---

# 10. Create Backup Directory

```bash
mkdir -p -- "$backup_dir"
```

### `mkdir`

Directory create karta hai.

### `-p`

Agar directory already exist karti hai to unnecessary error nahi deta.

Missing parent directories bhi create kar sakta hai.

Example:

```bash
mkdir -p ./backups
```

### `--`

Options ka end indicate karta hai.

Iske baad input ko path/filename samjha jata hai.

---

# 11. `create_backup` Function

```bash
function create_backup {
```

Is function ka kaam:

> Actual ZIP backup create karna.

---

# 12. Backup Filename Banana

```bash
backup_file="${backup_dir}/backup_${timestamp}.zip"
```

Example:

```text
backup_dir = ./backups
timestamp  = 2026-09-02-11-30-45
```

Result:

```text
./backups/backup_2026-09-02-11-30-45.zip
```

---

# 13. User-Friendly Output

```bash
echo "Creating backup..."
echo "Source: $source_dir"
echo "Destination: $backup_file"
```

Ye user ko clearly batata hai:

```text
Source kaha hai?
Backup kaha ban raha hai?
```

---

# 14. ZIP Command

```bash
if zip -rq -- "$backup_file" "$source_dir"; then
```

### `zip`

ZIP archive banata hai.

### `-r`

Recursive.

Source folder ke andar subfolders aur files ko bhi include karta hai.

### `-q`

Quiet mode.

`adding:` wali verbose output hide karta hai.

### `--`

End of options.

### `"$backup_file"`

Destination ZIP file.

### `"$source_dir"`

Source directory.

---

# 15. Why Command Directly Inside `if`?

```bash
if zip ...; then
```

Bash ZIP command ka exit status check karta hai.

```text
0      = success
non-0  = failure
```

Success:

```bash
echo "Backup generated successfully."
```

Failure:

```bash
echo "Backup failed."
exit 1
```

Ye plain:

```bash
zip ...
echo "Backup successful"
```

se better hai, kyun ke plain echo command ZIP failure ko detect nahi karta.

---

# 16. `perform_rotation` Function

```bash
function perform_rotation {
```

Is function ka purpose:

> Latest required backups keep karna aur older backups remove karna.

---

# 17. Backups Array Load Karna

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

### `ls -t`

Files ko modification time ke hisaab se sort karta hai.

```text
newest
↓
older
↓
oldest
```

### Pattern

```bash
"${backup_dir}/backup_"*.zip
```

Sirf matching backup ZIP files select hongi.

### Array

```bash
backups=(...)
```

Output ko Bash array mein store karta hai.

Conceptually:

```text
backups[0] = newest
backups[1] = second newest
backups[2] = third newest
```

> Note: Ye learning-friendly method hai. Production mein filenames with spaces ki wajah se `ls` parsing avoid karna better hai.

---

# 18. Total Backups Count

```bash
echo "Total backups: ${#backups[@]}"
```

### `${#backups[@]}`

Array mein total elements count karta hai.

Example:

```bash
backups=(a b c d e f g)
```

Then:

```text
${#backups[@]} = 7
```

---

# 19. Retention Limit Display

```bash
echo "Backups to keep: $keep_backups"
```

User ko current retention policy dikhata hai.

Example:

```text
Backups to keep: 5
```

---

# 20. Rotation Condition

```bash
if [[ ${#backups[@]} -gt $keep_backups ]]; then
```

Meaning:

> Agar total backups retention limit se zyada hain to rotation perform karo.

Example:

```text
Total backups = 8
keep_backups  = 5
```

Condition true hogi.

---

# 21. Backups to Keep

```bash
backups_to_keep=("${backups[@]:0:$keep_backups}")
```

Array slicing.

Format:

```text
${array[@]:start:length}
```

Yahan:

```text
start  = 0
length = keep_backups
```

Agar:

```text
keep_backups=5
```

to:

```bash
"${backups[@]:0:5}"
```

indexes:

```text
0 1 2 3 4
```

return karega.

---

# 22. Backups to Remove

```bash
backups_to_remove=("${backups[@]:$keep_backups}")
```

Format:

```text
${array[@]:start}
```

Agar:

```text
keep_backups=5
```

to:

```bash
"${backups[@]:5}"
```

index 5 se last tak sab elements dega.

Example:

```text
Index 0 → KEEP
Index 1 → KEEP
Index 2 → KEEP
Index 3 → KEEP
Index 4 → KEEP

Index 5 → REMOVE
Index 6 → REMOVE
Index 7 → REMOVE
```

---

# 23. Print Backups Being Kept

```bash
printf '%s\n' "${backups_to_keep[@]}"
```

### `${backups_to_keep[@]}`

Array ke tamam elements.

### `printf '%s\n'`

Har element ko separate line par print karta hai.

---

# 24. Print Backups to Remove

```bash
printf '%s\n' "${backups_to_remove[@]}"
```

Example output:

```text
./backups/backup_old3.zip
./backups/backup_old2.zip
./backups/backup_old1.zip
```

---

# 25. `for` Loop

```bash
for backup in "${backups_to_remove[@]}"; do
```

Har old backup ko one-by-one `backup` variable mein assign karta hai.

Example:

```text
Iteration 1:
backup=backup_old3.zip

Iteration 2:
backup=backup_old2.zip
```

---

# 26. Removing Backups

```bash
rm -f -- "$backup"
```

### `rm`

File remove karta hai.

### `-f`

Force mode.

Prompt ke baghair remove karta hai.

### `--`

Options aur filenames ko separate karta hai.

### `"$backup"`

Current loop item.

---

# 27. Rotation Completion Message

```bash
echo "Backup rotation completed."
```

User ko confirmation milti hai ke rotation complete ho gayi.

---

# 28. When Rotation Is Not Required

```bash
else

    echo "Rotation not required."
fi
```

Agar total backups:

```text
<= keep_backups
```

hain to kuch delete nahi hoga.

Example:

```text
Total backups: 4
Backups to keep: 5
Rotation not required.
```

---

# 29. Main Section

```bash
create_backup
perform_rotation
```

Functions define karna unko run nahi karta.

Actual execution ke liye function call karna hota hai.

Order important hai:

```text
create_backup
      ↓
perform_rotation
```

Pehle new backup create hota hai.

Phir total backup count aur rotation check hoti hai.

---

# Full Script Flow

```text
START
  ↓
Check argument count
  ↓
2 or 3 arguments?
 ├── NO → Usage → exit 1
 └── YES
       ↓
Set source_dir
Set backup_dir
Set keep_backups
Set timestamp
       ↓
Source directory exists?
 ├── NO → Error → exit 1
 └── YES
       ↓
keep_backups valid integer?
 ├── NO → Error → exit 1
 └── YES
       ↓
zip command available?
 ├── NO → Error → exit 1
 └── YES
       ↓
Create/check backup directory
       ↓
create_backup
       ↓
ZIP successful?
 ├── NO → exit 1
 └── YES
       ↓
perform_rotation
       ↓
Load backups newest first
       ↓
Count backups
       ↓
Count > keep_backups?
 ├── NO → No rotation
 └── YES
       ↓
Select backups to keep
       ↓
Select backups to remove
       ↓
Loop through old backups
       ↓
Delete each old backup
       ↓
END
```

---

# How to Run

## Default: Keep 5 Backups

```bash
./backup.sh ./data ./backups
```

Meaning:

```text
$1 = ./data
$2 = ./backups
$3 = missing

keep_backups = 5
```

---

## Keep 10 Backups

```bash
./backup.sh ./data ./backups 10
```

Meaning:

```text
$1 = ./data
$2 = ./backups
$3 = 10

keep_backups = 10
```

---

# Important Bash Concepts Learned

```text
$0                    = script name
$1                    = first argument
$2                    = second argument
$3                    = third argument
$#                    = total number of arguments

"${3:-5}"             = use $3, otherwise default to 5

-lt                   = less than
-gt                   = greater than
||                    = OR
!                     = NOT

-d                    = directory test
=~                    = regex matching

$(command)            = command substitution

command -v            = check command availability

mkdir -p              = create directory if needed

zip -r                = recursive ZIP
zip -q                = quiet mode

"${#array[@]}"        = number of array elements
"${array[@]}"         = all elements
"${array[@]:0:N}"     = first N elements
"${array[@]:N}"       = index N to end

for ... do ... done   = loop

rm -f -- "$file"      = safely remove a file
```

---

# Suggested Lecture Progression

```text
Step 1
Arguments: $1 $2 $3

Step 2
Optional argument:
${3:-5}

Step 3
Input validation

Step 4
Directory test

Step 5
Dependency check

Step 6
Timestamp

Step 7
Functions

Step 8
ZIP backup

Step 9
Arrays

Step 10
Array count

Step 11
Array slicing

Step 12
for loop

Step 13
Backup rotation
```

---

# Production Note

For learning:

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

is easy to understand.

For production, `ls` output parsing is not ideal because filenames can contain spaces or unusual characters.

Next level:

```text
find
 ↓
sort
 ↓
mapfile
 ↓
null-separated records
```

This can be introduced after students fully understand arrays and rotation logic.

---

# Final Memory Flow

```text
VALIDATE
   ↓
PREPARE
   ↓
BACKUP
   ↓
COUNT
   ↓
KEEP N
   ↓
REMOVE OLD
```
