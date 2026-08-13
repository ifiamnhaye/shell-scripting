# Bash `cp` Command Error Handling — Study Notes

## Example Script

```bash
if cp -- "$source" "$destination"; then
    echo "Backup completed"
else
    echo "Error: backup failed" >&2
    exit 1
fi
```

## Purpose

This code:

1. Attempts to copy a source file or directory.
2. Checks whether the `cp` command succeeded.
3. Displays a success message only after a successful copy.
4. Displays an error message and stops the script when the copy fails.

## Line-by-Line Explanation

### 1. Run the `cp` Command

```bash
if cp -- "$source" "$destination"; then
```

Bash runs:

```bash
cp -- "$source" "$destination"
```

The variables contain:

- `"$source"` — the file or directory being copied.
- `"$destination"` — where the source should be copied.

Example:

```bash
source="report.txt"
destination="backup/"
```

The command becomes:

```bash
cp -- "report.txt" "backup/"
```

## Why Are Variables Quoted?

```bash
"$source"
"$destination"
```

Double quotes preserve each path as one argument.

For example:

```bash
source="my report.txt"
destination="backup folder/"
```

Without quotes, Bash could split each path at its spaces.

Correct:

```bash
cp -- "$source" "$destination"
```

## What Does `--` Mean?

```bash
cp -- "$source" "$destination"
```

`--` tells `cp` that command options have ended.

Everything after `--` should be treated as a path, even when a filename begins
with a hyphen.

Example filename:

```text
-report.txt
```

Without `--`, `cp` might interpret that name as an option. Using `--` is a good
safety practice for user-supplied paths.

## How Does `if` Check the Command?

The `if` statement checks the exit status returned by `cp`.

| Exit status | Meaning | Branch |
|---:|---|---|
| `0` | Copy succeeded | `then` |
| Nonzero | Copy failed | `else` |

You do not need to check `$?` separately because `if` tests the command
directly.

## Success Branch

```bash
echo "Backup completed"
```

This line runs only when `cp` returns status `0`.

Therefore, the script does not display a false success message after a failed
copy.

## Failure Branch

```bash
else
    echo "Error: backup failed" >&2
    exit 1
```

This branch runs when `cp` returns a nonzero status.

### Error Message

```bash
echo "Error: backup failed" >&2
```

`>&2` sends the message to **standard error**, also called `stderr`.

| Stream | Descriptor | Purpose |
|---|---:|---|
| stdin | `0` | Input |
| stdout | `1` | Normal output |
| stderr | `2` | Errors and diagnostics |

This allows normal output and error output to be saved separately:

```bash
./backup.sh > output.log 2> error.log
```

### Stop with Failure

```bash
exit 1
```

This:

- Stops the script.
- Returns status `1`.
- Tells a calling process that the backup failed.

Status `0` normally means success. A nonzero status normally represents failure
or another documented condition.

## Closing the Conditional

```bash
fi
```

`fi` closes the Bash `if` statement.

## Execution Flow

```text
Run cp
  |
  +-- Status 0 --------> Display "Backup completed"
  |
  +-- Nonzero status --> Send error to stderr --> exit 1
```

## Complete Practice Script

```bash
#!/bin/bash

# Purpose: Copy one source to a backup destination
# Usage: ./backup.sh SOURCE DESTINATION

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 SOURCE DESTINATION" >&2
    exit 2
fi

source="$1"
destination="$2"

if [[ ! -e "$source" ]]; then
    echo "Error: source does not exist: $source" >&2
    exit 3
fi

if cp -- "$source" "$destination"; then
    echo "Backup completed"
else
    echo "Error: backup failed" >&2
    exit 1
fi
```

## Example Usage

```bash
chmod u+x backup.sh
./backup.sh report.txt backup/
```

Check the script status:

```bash
echo "$?"
```

## Why This Approach Is Better

Unsafe approach:

```bash
cp "$source" "$destination"
echo "Backup completed"
```

The success message runs even if `cp` fails.

Safer approach:

```bash
if cp -- "$source" "$destination"; then
    echo "Backup completed"
else
    echo "Error: backup failed" >&2
    exit 1
fi
```

The message `Backup completed` is displayed only after verified success.

## Key Points

- `if` can test a command directly.
- Exit status `0` selects the `then` branch.
- A nonzero status selects the `else` branch.
- Quote path variables.
- Use `--` before user-supplied paths where supported.
- Send error messages to stderr using `>&2`.
- Use a nonzero exit status when a required operation fails.
- Never display success before confirming that the command succeeded.

