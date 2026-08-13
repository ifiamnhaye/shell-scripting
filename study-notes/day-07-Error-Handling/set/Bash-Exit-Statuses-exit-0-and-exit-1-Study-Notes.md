# Bash Exit Statuses: `exit 0` and `exit 1` — Study Notes

## Table of Contents

- [Introduction](#introduction)
- [Basic Rule](#basic-rule)
- [`exit 0`: Success](#exit-0-success)
- [`exit 1`: Failure](#exit-1-failure)
- [Check Status with `$?`](#check-status-with-)
- [Why Exit Statuses Matter](#why-exit-statuses-matter)
- [Input-Validation Example](#input-validation-example)
- [Help Requests](#help-requests)
- [Root-Permission Example](#root-permission-example)
- [Commands After `exit`](#commands-after-exit)
- [Behavior Without Explicit `exit`](#behavior-without-explicit-exit)
- [`exit` Versus `return`](#exit-versus-return)
- [Custom Exit Statuses](#custom-exit-statuses)
- [Common Mistakes](#common-mistakes)
- [Quick Reference](#quick-reference)
- [Key Lesson](#key-lesson)

## Introduction

In Bash scripting, `exit` terminates the entire script and returns a status number to the operating system, parent shell, calling script, CI/CD pipeline, scheduler, or monitoring system.

Syntax:

```bash
exit STATUS
```

The two most common statuses are:

```bash
exit 0
exit 1
```

## Basic Rule

| Exit status | General meaning |
|---:|---|
| `0` | Success |
| Non-zero | Failure or another special condition |
| `1` | General failure |

The Bash convention is:

```text
0 = success
1 = failure
```

## `exit 0`: Success

```bash
exit 0
```

This means:

> Stop the script and report successful completion.

Example:

```bash
#!/bin/bash

echo "Backup completed successfully."
exit 0
```

Run and check it:

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

This means:

> Stop the script and report a general failure.

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

If the file does not exist, the script displays an error and exits with status `1` before reaching the success section.

## Check Status with `$?`

```bash
echo $?
```

`$?` contains the status of the most recently completed foreground command, script, or pipeline.

Check it immediately:

```bash
bash backup.sh
echo $?
```

The value changes after another command runs. This can be misleading:

```bash
bash backup.sh
echo "Script finished"
echo $?
```

The final status belongs to `echo "Script finished"`, not to `backup.sh`.

Save the status when it will be needed later:

```bash
bash backup.sh
status=$?

echo "Backup status: $status"
```

## Why Exit Statuses Matter

Automation uses the status to decide whether a task succeeded.

Example using `$?`:

```bash
bash backup.sh

if [[ "$?" -eq 0 ]]; then
    echo "The backup script succeeded."
else
    echo "The backup script failed."
fi
```

A cleaner approach tests the script directly:

```bash
if bash backup.sh; then
    echo "The backup script succeeded."
else
    echo "The backup script failed."
fi
```

Exit statuses are used by:

- Other scripts
- Cron jobs
- Systemd services
- CI/CD pipelines
- Monitoring systems
- Deployment automation

## Input-Validation Example

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

Missing input:

```bash
bash number.sh
```

Result:

```text
Usage: number.sh NUMBER
Exit status: 1
```

Valid input:

```bash
bash number.sh 10
```

Result:

```text
Valid number: 10
Exit status: 0
```

## Help Requests

Displaying requested help is normally successful:

```bash
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 <directory>"
    exit 0
fi
```

The user requested help and the script provided it, so `exit 0` is appropriate.

If usage is displayed because required input is missing, report failure:

```bash
if [[ "$#" -ne 1 ]]; then
    echo "Error: one directory is required." >&2
    echo "Usage: $0 <directory>" >&2
    exit 1
fi
```

## Root-Permission Example

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

Without sudo:

```bash
bash admin.sh
```

The script exits with status `1` because its EUID is not `0`.

With sudo:

```bash
sudo bash admin.sh
```

The root check succeeds, and the script can complete with status `0`.

## Commands After `exit`

Commands after an executed `exit` do not run:

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

The `echo "After exit"` command is never reached.

## Behavior Without Explicit `exit`

If a script reaches the end without an explicit `exit`, it normally returns the status of its last executed command.

```bash
#!/bin/bash

echo "Completed"
```

Because `echo` normally succeeds, this script normally returns `0`.

An explicit status makes the intended result clear:

```bash
exit 0
```

## `exit` Versus `return`

Use `exit` to terminate the entire script:

```bash
exit 1
```

Use `return` to leave the current function:

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

| Command | Effect |
|---|---|
| `exit 0` | Terminate the entire script successfully |
| `exit 1` | Terminate the entire script with failure |
| `return 0` | Leave the current function successfully |
| `return 1` | Leave the current function with failure |

Use the function status:

```bash
if check_file "report.txt"; then
    echo "Continue processing."
else
    echo "Cannot continue." >&2
    exit 1
fi
```

## Custom Exit Statuses

A script can assign different non-zero statuses to different problems:

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

| Status | Script-defined meaning |
|---:|---|
| `0` | Success |
| `1` | General error |
| `2` | Incorrect arguments |
| `3` | Directory does not exist |

Custom meanings should be documented in the script's help or README.

Bash statuses are normally interpreted within this range:

```text
0–255
```

For beginner scripts, `0` for success and `1` for general failure are usually sufficient.

## Common Mistakes

### Reporting failure after success

Incorrect:

```bash
echo "Backup completed."
exit 1
```

Correct:

```bash
echo "Backup completed."
exit 0
```

### Reporting success after failure

Incorrect:

```bash
echo "Error: backup failed." >&2
exit 0
```

Correct:

```bash
echo "Error: backup failed." >&2
exit 1
```

### Checking `$?` after another command

```bash
bash backup.sh
echo "Checking status"
echo $?
```

The displayed status belongs to the first `echo`, not necessarily to `backup.sh`.

### Using `exit` inside a function unintentionally

```bash
check_file()
{
    exit 1
}
```

This terminates the complete script. Use `return 1` if only the function should stop.

## Quick Reference

| Expression | Meaning |
|---|---|
| `exit 0` | Stop the script and report success |
| `exit 1` | Stop the script and report general failure |
| `exit 2` | Stop with a custom non-zero status |
| `$?` | Status of the most recently completed command |
| `status=$?` | Save the most recent status |
| `return 0` | Leave a function successfully |
| `return 1` | Leave a function with failure |
| `>&2` | Send a message to standard error |
| `0–255` | Normal interpreted exit-status range |

## Key Lesson

```bash
exit 0
```

means:

> Stop the script and report success.

```bash
exit 1
```

means:

> Stop the script and report failure.

Check the previous command or script immediately with:

```bash
echo $?
```

