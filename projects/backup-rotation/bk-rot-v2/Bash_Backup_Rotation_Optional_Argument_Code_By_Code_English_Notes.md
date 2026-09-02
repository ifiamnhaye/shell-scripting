# Bash Backup Rotation Script — Code-by-Code English Study Notes

## backup_rotation.sh

```bash
#!/bin/bash

function display_usage {
    echo "Usage: $0 <source_directory> <backup_directory> [keep_backups]"
    echo
    echo "Example:"
    echo "  $0 ./data ./backups"
    echo "  $0 ./data ./backups 10"
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
    display_usage
    exit 1
fi

source_dir="$1"
backup_dir="$2"
keep_backups="${3:-5}"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

if [[ ! -d "$source_dir" ]]; then
    echo "Error: Source directory does not exist:"
    echo "$source_dir"
    exit 1
fi

if ! [[ "$keep_backups" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: keep_backups must be a positive integer."
    echo "Example: 5, 10, 15"
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip command is not installed."
    echo "Install it first and run the script again."
    exit 1
fi

mkdir -p -- "$backup_dir"

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

function perform_rotation {

    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    echo
    echo "Total backups: ${#backups[@]}"
    echo "Backups to keep: $keep_backups"

    if [[ ${#backups[@]} -gt $keep_backups ]]; then

        echo
        echo "Performing backup rotation..."

        backups_to_keep=("${backups[@]:0:$keep_backups}")
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

create_backup
perform_rotation
```

---

# 1. Shebang

```bash
#!/bin/bash
```

This tells Linux to run the script using the Bash interpreter.

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

This function shows the correct way to run the script.

### `$0`

```bash
$0
```

Represents the current script name.

If the script is called:

```text
backup.sh
```

then:

```bash
echo "$0"
```

may print:

```text
./backup.sh
```

### `[keep_backups]`

Square brackets in usage documentation normally indicate an **optional argument**.

So both of these are valid:

```bash
./backup.sh ./data ./backups
```

```bash
./backup.sh ./data ./backups 10
```

---

# 3. Validate the Number of Arguments

```bash
if [[ $# -lt 2 || $# -gt 3 ]]; then
    display_usage
    exit 1
fi
```

### `$#`

Returns the total number of command-line arguments.

Example:

```bash
./backup.sh ./data ./backups 10
```

Then:

```text
$# = 3
```

### `-lt`

Means:

> less than

### `-gt`

Means:

> greater than

### `||`

Means:

> OR

Therefore:

```bash
[[ $# -lt 2 || $# -gt 3 ]]
```

means:

> If the number of arguments is less than 2 OR greater than 3, the input is invalid.

Valid:

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

Stops the script with a failure status.

---

# 4. Store Positional Arguments in Variables

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

```text
source_dir = ./data
backup_dir = ./backups
```

Quoting variables is good practice because paths may contain spaces.

---

# 5. Optional Third Argument with a Default Value

```bash
keep_backups="${3:-5}"
```

This means:

> Use `$3` if it is provided and non-empty; otherwise use `5`.

Example 1:

```bash
./backup.sh ./data ./backups
```

Result:

```text
keep_backups = 5
```

Example 2:

```bash
./backup.sh ./data ./backups 10
```

Result:

```text
keep_backups = 10
```

General form:

```text
${variable:-default}
```

---

# 6. Create a Timestamp

```bash
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
```

### `$(...)`

This is called **command substitution**.

It runs a command and stores its output in a variable.

Example:

```bash
date '+%Y-%m-%d-%H-%M-%S'
```

Possible output:

```text
2026-09-02-11-30-45
```

So the backup filename can become:

```text
backup_2026-09-02-11-30-45.zip
```

---

# 7. Validate the Source Directory

```bash
if [[ ! -d "$source_dir" ]]; then
```

### `-d`

Checks whether a path exists and is a directory.

### `!`

Means:

> NOT

So:

```bash
[[ ! -d "$source_dir" ]]
```

means:

> If the source directory does not exist, show an error and stop.

---

# 8. Validate `keep_backups`

```bash
if ! [[ "$keep_backups" =~ ^[1-9][0-9]*$ ]]; then
```

This checks whether the retention value is a positive integer.

### `=~`

Bash regular-expression matching operator.

### Regex

```text
^[1-9][0-9]*$
```

Breakdown:

```text
^        = start of string
[1-9]    = first digit must be 1 through 9
[0-9]*   = followed by zero or more digits
$        = end of string
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

---

# 9. Check Whether `zip` Is Installed

```bash
if ! command -v zip >/dev/null 2>&1; then
```

### `command -v zip`

Checks whether the `zip` command is available.

Manual test:

```bash
command -v zip
```

Possible output:

```text
/usr/bin/zip
```

### `>/dev/null`

Hides normal output.

### `2>&1`

Sends standard error to the same destination as standard output.

Together:

```bash
>/dev/null 2>&1
```

means:

> Hide both normal output and error output.

---

# 10. Create the Backup Directory

```bash
mkdir -p -- "$backup_dir"
```

### `mkdir`

Creates a directory.

### `-p`

Creates missing parent directories and does not complain if the directory already exists.

### `--`

Marks the end of command options.

Everything after `--` is treated as a path or filename.

---

# 11. `create_backup` Function

```bash
function create_backup {
```

This function creates the actual ZIP backup.

---

# 12. Build the Backup Filename

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

# 13. Display Source and Destination

```bash
echo "Creating backup..."
echo "Source: $source_dir"
echo "Destination: $backup_file"
```

This gives the user clear visibility into what is being backed up and where the archive is being created.

---

# 14. ZIP Command

```bash
if zip -rq -- "$backup_file" "$source_dir"; then
```

### `zip`

Creates a ZIP archive.

### `-r`

Recursive mode.

Includes files and subdirectories.

### `-q`

Quiet mode.

Hides the normal `adding:` output.

### `--`

Marks the end of command options.

### `"$backup_file"`

Destination ZIP archive.

### `"$source_dir"`

Source directory to back up.

---

# 15. Why Put the ZIP Command Directly in `if`?

```bash
if zip ...; then
```

Bash checks the command's exit status.

```text
0      = success
non-0  = failure
```

On success:

```bash
echo "Backup generated successfully."
```

On failure:

```bash
echo "Backup failed."
exit 1
```

This is better than blindly printing a success message after the command.

---

# 16. `perform_rotation` Function

```bash
function perform_rotation {
```

This function keeps the required number of latest backups and removes older ones.

---

# 17. Load Backups into an Array

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

### `ls -t`

Sorts files by modification time:

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

Matches only backup ZIP files.

### Bash array

```bash
backups=(...)
```

Stores the command output in an array.

Conceptually:

```text
backups[0] = newest
backups[1] = second newest
backups[2] = third newest
```

> This is a simple learning approach. In production, parsing `ls` output is not ideal when filenames may contain spaces or unusual characters.

---

# 18. Count Total Backups

```bash
echo "Total backups: ${#backups[@]}"
```

### `${#backups[@]}`

Returns the number of elements in the array.

Example:

```bash
backups=(a b c d e f g)
```

Result:

```text
7
```

---

# 19. Display Retention Limit

```bash
echo "Backups to keep: $keep_backups"
```

This shows the current backup retention setting.

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

> If the total number of backups is greater than the retention limit, perform rotation.

Example:

```text
Total backups = 8
keep_backups  = 5
```

The condition is true.

---

# 21. Select Backups to Keep

```bash
backups_to_keep=("${backups[@]:0:$keep_backups}")
```

This uses Bash array slicing.

General format:

```text
${array[@]:start:length}
```

If:

```text
keep_backups = 5
```

then:

```bash
"${backups[@]:0:5}"
```

selects indexes:

```text
0 1 2 3 4
```

---

# 22. Select Backups to Remove

```bash
backups_to_remove=("${backups[@]:$keep_backups}")
```

General format:

```text
${array[@]:start}
```

If:

```text
keep_backups = 5
```

then:

```bash
"${backups[@]:5}"
```

selects index 5 through the end.

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

`printf` prints each array element on its own line.

---

# 24. Print Backups to Remove

```bash
printf '%s\n' "${backups_to_remove[@]}"
```

Example:

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

Processes every old backup one at a time.

Example:

```text
Iteration 1:
backup=backup_old3.zip

Iteration 2:
backup=backup_old2.zip
```

---

# 26. Remove Old Backups

```bash
rm -f -- "$backup"
```

### `rm`

Removes a file.

### `-f`

Force mode.

### `--`

Marks the end of options.

### `"$backup"`

The current backup file being processed by the loop.

---

# 27. Rotation Completion Message

```bash
echo "Backup rotation completed."
```

Confirms that the rotation finished.

---

# 28. When Rotation Is Not Required

```bash
else
    echo "Rotation not required."
fi
```

If:

```text
total backups <= keep_backups
```

nothing is deleted.

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

Defining a function does not execute it.

The functions must be called.

Order:

```text
create_backup
      ↓
perform_rotation
```

First create the new backup, then check whether rotation is required.

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
keep_backups is a valid positive integer?
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

# How to Run the Script

## Default — Keep 5 Backups

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

# Quick Revision

```text
$0                    = script name
$1                    = first argument
$2                    = second argument
$3                    = third argument
$#                    = number of arguments

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
"${array[@]}"         = all array elements
"${array[@]:0:N}"     = first N elements
"${array[@]:N}"       = index N to the end

for ... do ... done   = loop

rm -f -- "$file"      = safely remove file
```

---

# Suggested Lecture Progression

1. Positional arguments: `$1`, `$2`, `$3`
2. Argument count: `$#`
3. Optional third argument: `${3:-5}`
4. Input validation
5. Directory validation
6. Dependency check
7. Timestamp
8. Functions
9. ZIP backup
10. Arrays
11. Array count
12. Array slicing
13. `for` loop
14. Backup rotation

---

# Production Note

For learning:

```bash
backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))
```

is easy to understand.

For production, parsing `ls` output is not ideal because filenames can contain spaces or unusual characters.

A safer next level is:

```text
find
 ↓
sort
 ↓
mapfile
 ↓
null-separated records
```

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
