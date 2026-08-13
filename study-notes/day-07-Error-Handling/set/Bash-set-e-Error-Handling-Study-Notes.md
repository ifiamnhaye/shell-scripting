# Bash `set -e` Error Handling — Study Notes

## Table of Contents

- [Introduction](#introduction)
- [Exit Status Refresher](#exit-status-refresher)
- [Basic Example](#basic-example)
- [Without `set -e`](#without-set--e)
- [With `set -e`](#with-set--e)
- [Situations Where Bash Does Not Immediately Exit](#situations-where-bash-does-not-immediately-exit)
- [Pipelines and `pipefail`](#pipelines-and-pipefail)
- [Strict-Mode Combination](#strict-mode-combination)
- [Practical Script](#practical-script)
- [Important Limitations](#important-limitations)
- [Best Practices](#best-practices)
- [Quick Summary](#quick-summary)

## Introduction

`set -e` is a Bash error-handling option:

```bash
set -e
```

It tells Bash:

> Exit the script when an unhandled command fails with a non-zero exit status.

It helps prevent a script from continuing after an important command has failed.

## Exit Status Refresher

Every Linux command returns an exit status after it finishes.

| Exit status | Meaning |
|---:|---|
| `0` | Success |
| Non-zero | Failure, warning, or another special condition |

Check the previous command's exit status with:

```bash
echo $?
```

Example:

```bash
mkdir /tmp/bash-practice
echo $?
```

If `mkdir` succeeds, the expected status is:

```text
0
```

## Basic Example

```bash
#!/bin/bash

set -e

echo "Creating directory"
mkdir /root/example-directory

echo "Creating file"
touch /root/example-directory/test.txt

echo "Script completed"
```

If `mkdir` fails, Bash normally terminates the script at that point. The `touch` command and final success message do not run.

## Without `set -e`

```bash
#!/bin/bash

cp missing-file.txt /tmp/

echo "Backup completed"
```

Possible output:

```text
cp: cannot stat 'missing-file.txt': No such file or directory
Backup completed
```

The script continues after `cp` fails and prints a misleading success message.

## With `set -e`

```bash
#!/bin/bash

set -e

cp missing-file.txt /tmp/

echo "Backup completed"
```

When `cp` fails, Bash exits before reaching:

```bash
echo "Backup completed"
```

The script's exit status will be non-zero.

## Situations Where Bash Does Not Immediately Exit

`set -e` has important exceptions. Bash does not immediately terminate when a command's status is being tested or intentionally handled.

### Failure tested by `if`

```bash
if cp -- "$source" "$destination"; then
    echo "Copy completed"
else
    echo "Copy failed" >&2
fi
```

The `if` statement needs the exit status of `cp` to choose a branch, so the failure is handled by the conditional.

### Failure tested with `!`

```bash
if ! mkdir "$directory"; then
    echo "Could not create directory" >&2
fi
```

`!` reverses the result, and `if` handles it.

### Failure handled with `||`

```bash
mkdir /tmp/project || echo "Could not create directory" >&2
```

The command after `||` runs when `mkdir` fails.

For a critical failure, explicitly exit:

```bash
mkdir /tmp/project || {
    echo "Could not create directory" >&2
    exit 1
}
```

### Success flow controlled with `&&`

```bash
mkdir /tmp/project && echo "Directory created"
```

The success message runs only if `mkdir` succeeds.

### Conditions in loops

Commands used as the condition of `while` or `until` loops are also tested by Bash and do not normally trigger an immediate `set -e` exit.

```bash
while ping -c 1 server.example.com &>/dev/null
do
    echo "Server is reachable"
    break
done
```

## Pipelines and `pipefail`

Consider this pipeline:

```bash
grep "error" missing-file.txt | sort
```

By default, a pipeline's status is normally the status of its final command. `grep` can fail while `sort` still succeeds.

Use `pipefail` so the pipeline is considered unsuccessful if any command in it fails:

```bash
set -e
set -o pipefail
```

The shorter form is:

```bash
set -eo pipefail
```

Example:

```bash
#!/bin/bash

set -eo pipefail

grep "error" missing-file.txt | sort

echo "Search completed"
```

If `grep` cannot read the file, the pipeline fails and the final message is not printed.

## Strict-Mode Combination

A commonly used Bash safety combination is:

```bash
set -Eeuo pipefail
```

| Option | Purpose |
|---|---|
| `-e` | Exit after an unhandled command failure |
| `-E` | Allow `ERR` traps to be inherited by functions and subshell contexts |
| `-u` | Treat the use of an unset variable as an error |
| `-o pipefail` | Fail a pipeline if any command in it fails |

Strict mode improves safety, but each option has behavior that should be understood and tested.

## Practical Script

```bash
#!/bin/bash

set -Eeuo pipefail

source_file="${1:-}"
destination="/tmp/backup"

if [[ -z "$source_file" ]]; then
    echo "Usage: $0 SOURCE_FILE" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist: $source_file" >&2
    exit 1
fi

mkdir -p "$destination"
cp -- "$source_file" "$destination/"

echo "Backup completed successfully"
```

Run it with:

```bash
bash backup.sh report.txt
```

The script:

1. Enables safer Bash behavior.
2. Reads the source filename from `$1`.
3. Uses `${1:-}` to avoid an unset-variable error under `set -u`.
4. Validates that an argument was supplied.
5. Validates that the source is a regular file.
6. Creates the destination directory.
7. Copies the file.
8. Prints success only after the copy succeeds.

## Important Limitations

`set -e` is useful, but it is not a complete error-handling system.

- It has exceptions in conditionals, loops, `!`, `&&`, and `||` lists.
- Pipelines need `set -o pipefail` for stronger failure detection.
- It does not automatically provide a meaningful error message.
- Some commands use non-zero statuses for normal conditions. For example, `grep` returns `1` when it finds no matching lines.
- A script should not depend on `set -e` without testing both successful and failure paths.

For example, this relies only on automatic termination:

```bash
set -e
cp -- "$source" "$destination"
```

This version gives the user a clearer explanation:

```bash
if ! cp -- "$source" "$destination"; then
    echo "Error: could not copy '$source' to '$destination'." >&2
    exit 1
fi
```

Use explicit handling when a command is important enough to require a specific recovery action or error message.

## Best Practices

1. Place `set -e` near the beginning of the script.
2. Combine it with `pipefail` when pipelines are used.
3. Validate user input before running important commands.
4. Use clear error messages and send them to standard error with `>&2`.
5. Explicitly handle commands when recovery or cleanup is required.
6. Quote variables containing filenames and paths.
7. Test successful, unsuccessful, and unusual inputs.
8. Check script syntax before execution:

   ```bash
   bash -n script.sh
   ```

9. Trace the script during troubleshooting:

   ```bash
   bash -x script.sh
   ```

## Quick Summary

| Syntax | Meaning |
|---|---|
| `set -e` | Exit when an unhandled command fails |
| `set +e` | Disable the `-e` option |
| `set -o pipefail` | Detect a failure anywhere in a pipeline |
| `set -u` | Treat unset variables as errors |
| `set -E` | Inherit `ERR` traps in more contexts |
| `set -Eeuo pipefail` | Common strict-mode combination |

## Key Lesson

> `set -e` is an additional safety feature. It does not replace input validation, meaningful error messages, explicit recovery, cleanup, and careful testing.

