# Bash Backup Rotation Script — Block-by-Block Study Notes

## backup_rotation.sh

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

This tells Linux to run the script with Bash.

```text
/bin/bash = Bash interpreter
```

---

## 2. Usage Function

```bash
function display_usage {
    echo "Usage: ./backup.sh <path to your source> <path to backup folder>"
}
```

This function displays the correct way to run the script.

Example:

```bash
./backup.sh ./data ./backups
```

A function is a reusable block of commands.

---

## 3. Argument Validation

```bash
if [ $# -ne 2 ]; then
    display_usage
    exit 1
fi
```

The script requires exactly two arguments.

```text
$1 = source directory
$2 = backup directory
$# = total number of arguments
```

`-ne` means **not equal**.

So:

```bash
[ $# -ne 2 ]
```

means:

> If the number of arguments is not equal to 2.

Then:

```bash
display_usage
exit 1
```

shows the usage message and stops the script.

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

## 4. Store Arguments in Variables

```bash
source_dir="$1"
backup_dir="$2"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

If the user runs:

```bash
./backup.sh ./data ./backups
```

then:

```text
source_dir = ./data
backup_dir = ./backups
```

---

## 5. Timestamp

```bash
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

`$(...)` is called **command substitution**.

It runs a command and stores its output in a variable.

Example:

```bash
date '+%Y-%m-%d-%H-%M-%S'
```

Possible output:

```text
2026-09-02-11-30-45
```

This gives every backup a unique name.

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

Purpose:

> Create a ZIP backup of the source directory.

---

## 7. ZIP Command

```bash
zip -r "${backup_dir}/backup_${timestamp}.zip" "$source_dir"
```

### `zip`

Creates a ZIP archive.

### `-r`

Means **recursive**.

It includes files, subdirectories, and files inside those subdirectories.

Example:

```text
data/
├── file1.txt
├── file2.txt
└── logs/
    └── app.log
```

All of this is included in the ZIP file.

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

The backup file becomes:

```text
./backups/backup_2026-09-02-11-30-45.zip
```

---

## 9. Why Put `zip` Directly Inside `if`?

```bash
if zip -r ...; then
```

Bash checks the exit status of the `zip` command.

```text
0     = success
non-0 = failure
```

If ZIP succeeds:

```bash
echo "Backup generated successfully for ${timestamp}"
```

If ZIP fails:

```bash
echo "Backup failed"
exit 1
```

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

---

## 10. `perform_rotation` Function

```bash
function perform_rotation {
```

Purpose:

> Keep only the latest 5 backups and remove older backups.

---

## 11. Load Backups Into an Array

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

### `ls -t`

Sorts files by modification time, newest first.

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

Matches files such as:

```text
backup_2026-09-02-10-00-00.zip
backup_2026-09-02-11-00-00.zip
```

### `2>/dev/null`

Redirects error output to `/dev/null`.

```text
2 = stderr
/dev/null = discard destination
```

This hides errors such as "no matching backup files".

---

## 12. Bash Array

```bash
backups=(...)
```

The command output is stored in a Bash array.

Conceptually:

```text
backups[0] = newest backup
backups[1] = second newest
backups[2] = third newest
```

Bash array indexing starts at `0`.

---

## 13. Count the Backups

```bash
if [ "${#backups[@]}" -gt 5 ]; then
```

### `${#backups[@]}`

Returns the total number of elements in the array.

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

Means:

> greater than

So:

```bash
[ "${#backups[@]}" -gt 5 ]
```

means:

> If the total number of backups is greater than 5.

---

## 14. Keep the Latest 5

Because `ls -t` puts the newest backup first:

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

---

## 15. Array Slicing

```bash
backups_to_remove=("${backups[@]:5}")
```

### `${backups[@]}`

Means all array elements.

### `:5`

Means:

> Start from index 5 and continue to the end.

So:

```bash
backups_to_remove=("${backups[@]:5}")
```

means:

> Skip the latest 5 backups and store all older backups in `backups_to_remove`.

---

## 16. Useful Array Slicing Examples

### All elements

```bash
"${backups[@]}"
```

### First 5 elements

```bash
"${backups[@]:0:5}"
```

### Index 5 to the end

```bash
"${backups[@]:5}"
```

### Number of elements

```bash
"${#backups[@]}"
```

---

## 17. Display Backups To Remove

```bash
echo "Backups to remove:"
printf '%s\n' "${backups_to_remove[@]}"
```

`printf` prints each backup on a separate line.

Example:

```text
backup_03.zip
backup_02.zip
backup_01.zip
```

---

## 18. `for` Loop

```bash
for backup in "${backups_to_remove[@]}"; do
```

This processes each array element one by one.

Example:

```text
1st iteration:
backup="backup_03.zip"

2nd iteration:
backup="backup_02.zip"

3rd iteration:
backup="backup_01.zip"
```

---

## 19. Remove Old Backup

```bash
rm -f -- "$backup"
```

### `rm`

Removes a file.

### `-f`

Force mode. It does not prompt for confirmation.

### `--`

Marks the end of command options.

Anything after `--` is treated as a filename.

This is useful for unusual filenames such as:

```text
-test.zip
```

---

## 20. When Rotation Is Not Required

```bash
else
    echo "Rotation not required. Total backups: ${#backups[@]}"
fi
```

If there are 5 or fewer backups, nothing is deleted.

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

Defining a function does not execute it.

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

The script first creates the new backup, then performs rotation.

---

# Complete Script Flow

```text
START
  ↓
Check arguments
  ↓
Exactly 2?
 ├── NO → Display Usage → exit 1
 │
 └── YES
       ↓
Set source_dir
Set backup_dir
Create timestamp
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
Load backups newest first
       ↓
Count backups
       ↓
More than 5?
 ├── NO → Rotation not required
 │
 └── YES
       ↓
Keep indexes 0–4
       ↓
Select indexes 5–end
       ↓
Store in backups_to_remove
       ↓
Loop through old backups
       ↓
Delete each backup
       ↓
END
```

---

# Variable Naming Recommendation

For lecture clarity:

```bash
backups_to_remove
```

is clearer than:

```bash
old_backups
```

because the name explains exactly what will happen.

You can also demonstrate:

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

This learning version uses:

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

This is fine for classroom practice.

For production scripts, parsing `ls` output is not ideal because filenames may contain spaces or unusual characters.

A safer advanced approach is:

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

---

# Quick Revision

```text
#!/bin/bash           = use Bash interpreter

$#                    = total arguments
$1                    = first argument
$2                    = second argument

-ne                   = not equal
-gt                   = greater than

$(command)            = command substitution

zip -r                = recursively create ZIP

ls -t                 = newest files first

2>/dev/null           = hide stderr

"${#array[@]}"        = total array elements
"${array[@]}"         = all array elements
"${array[@]:0:5}"     = first 5 elements
"${array[@]:5}"       = index 5 to the end

for ... do ... done   = loop

rm -f -- "$file"      = safely remove file
```

---

# Suggested Lecture Delivery Order

1. Explain the problem: backup + rotation.
2. Show the required command-line arguments.
3. Explain `$1`, `$2`, and `$#`.
4. Validate exactly two arguments.
5. Create the timestamp.
6. Explain `zip -r`.
7. Explain command success/failure using `if`.
8. Load backups into an array.
9. Explain `ls -t`.
10. Count array elements.
11. Explain Bash array indexing.
12. Keep indexes `0–4`.
13. Slice from index `5` to the end.
14. Loop through backups to remove.
15. Delete old backup files.
16. Call the functions in the correct order.
17. Finish with the production note about `find + mapfile`.

---

# Final Concept

Remember the script as:

```text
Validate
   ↓
Backup
   ↓
Count
   ↓
Keep latest 5
   ↓
Remove older backups
```

This script practices:

- Bash arguments
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
