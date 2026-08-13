# Bash `set -e` Error Handling — English Study Notes

## Table of Contents

- [1. Basic Meaning](#1-basic-meaning)
- [2. Without `set -e`](#2-without-set--e)
- [3. With `set -e`](#3-with-set--e)
- [4. The Role of Exit Status](#4-the-role-of-exit-status)
- [5. Important Exceptions](#5-important-exceptions)
- [6. Pipelines and `pipefail`](#6-pipelines-and-pipefail)
- [7. Strict Mode](#7-strict-mode)
- [8. Explicit Error Handling](#8-explicit-error-handling)
- [9. Functions and Command Substitution](#9-functions-and-command-substitution)
- [10. Enabling and Disabling `set -e`](#10-enabling-and-disabling-set--e)
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

`set -e` is commonly described as **exit on error**.

Simple meaning:

> If an unhandled command fails with a nonzero status, stop the script instead of continuing.

Basic example:

```bash
#!/bin/bash

set -e

echo "Script started"
cp missing.txt backup.txt
echo "Script completed"
```

If `missing.txt` does not exist, `cp` fails. Because `set -e` is enabled, the script terminates at that point and `Script completed` is not printed.

Important:

> `set -e` is a safety option, not a complete error-handling system.

---

## 2. Without `set -e`

```bash
#!/bin/bash

echo "Before cp"
cp missing.txt backup.txt
echo "After cp"
```

If `cp` fails, Bash can normally continue with the next command.

Possible output:

```text
Before cp
cp: cannot stat 'missing.txt': No such file or directory
After cp
```

This may produce a false impression of success because the script continues after an important operation has failed.

---

## 3. With `set -e`

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

`After cp` is not printed.

The simplified flow is:

```text
Command succeeds -> continue the script
Command fails    -> set -e may terminate the script
```

The word **may** is important because `set -e` has context-dependent exceptions.

---

## 4. The Role of Exit Status

Every command returns a status when it finishes.

| Status | General meaning |
|---:|---|
| `0` | Success |
| Nonzero | Failure or another command-defined result |

Success example:

```bash
ls /etc/passwd
echo "$?"
```

A successful `ls` normally returns status `0`.

Failure example:

```bash
ls /missing-file
echo "$?"
```

A failed command returns a nonzero status. The exact value and its meaning are defined by the command.

Check or save `$?` immediately because every subsequent command replaces it:

```bash
cp source.txt backup.txt
status=$?
echo "cp status: $status"
```

`set -e` generally reacts to an unhandled nonzero status.

---

## 5. Important Exceptions

`set -e` does not guarantee that Bash will exit after **every** nonzero status. In several contexts, failure is being used to make a decision.

### Failure Inside `if`

```bash
if cp missing.txt backup.txt; then
    echo "Copy completed"
else
    echo "Copy failed" >&2
fi
```

The command status is being tested by `if`. If `cp` fails, Bash can execute the `else` block instead of exiting immediately.

### Failure with `!`

```bash
if ! mkdir new_directory; then
    echo "Directory could not be created" >&2
fi
```

`!` reverses the command's success/failure result, and the failure is explicitly being used as a condition.

### Failure with `||`

```bash
mkdir new_directory || echo "Directory creation failed" >&2
```

The first command's failure is part of an OR list, allowing the command on the right to run.

### Failure with `&&`

```bash
mkdir new_directory && echo "Directory created"
```

If the first command fails, the second command is skipped. The behavior of `set -e` in AND/OR lists differs from a simple standalone failure.

### Loop Conditions

A nonzero status used as the condition of `while` or `until` controls the loop. It does not necessarily cause the script to terminate.

### Core Lesson

> `set -e` is context-sensitive. Use explicit `if` handling for critical commands.

---

## 6. Pipelines and `pipefail`

Consider:

```bash
grep "ERROR" missing.log | wc -l
```

By default, a pipeline normally returns the status of its final command. If `grep` fails but `wc` completes successfully, the pipeline can return status `0`. In that case, `set -e` may not notice the earlier failure.

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

If `grep` cannot open its input file, the pipeline returns a nonzero status and the final `echo` does not run.

### Special Case: `grep`

`grep` returns:

| Status | Meaning |
|---:|---|
| `0` | At least one match was found. |
| `1` | No match was found. |
| Greater than `1` | An actual error occurred. |

No match may be an expected outcome, so handle it explicitly:

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

A common Bash safety combination is:

```bash
set -euo pipefail
```

| Option | Purpose |
|---|---|
| `-e` | Enables exit behavior for certain unhandled failures. |
| `-u` | Treats the use of an unset variable as an error. |
| `-o pipefail` | Exposes failures from earlier commands in a pipeline. |

Optional error-trap inheritance:

```bash
set -Eeuo pipefail
```

Capital `-E` improves inheritance of the `ERR` trap in functions, command substitutions, and subshell contexts.

Example:

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

When strict options are enabled, expected nonzero results must be handled deliberately.

---

## 8. Explicit Error Handling

Automatic exit only:

```bash
set -e
cp -- "$source_file" "$destination"
```

Clear error handling:

```bash
if ! cp -- "$source_file" "$destination"; then
    echo "Error: backup failed" >&2
    exit 1
fi
```

Benefits of explicit handling:

- The user receives a clear message.
- The failing operation is identified.
- Cleanup, retry, or recovery can be added.
- A suitable exit status can be returned.

To preserve the original command status, use an `else` block:

```bash
if cp -- "$source_file" "$destination"; then
    echo "Backup completed"
else
    status=$?
    echo "Error: backup failed with status $status" >&2
    exit "$status"
fi
```

Why not capture `$?` inside `if ! command; then`? The `!` operator reverses the result, so `$?` inside the `then` block can represent the negated status rather than the original command's failure status.

Final principle:

> Treat `set -e` as a safety net and use explicit `if/else` blocks for clear error handling.

---

## 9. Functions and Command Substitution

The behavior of `set -e` can be subtle in functions, command substitutions, subshells, and conditional contexts.

### Return a Clear Status from a Function

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

The function explicitly handles the failure and returns status `1`.

### Command Substitution

```bash
result=$(some_command)
```

Do not rely only on `set -e` for a critical command substitution:

```bash
if ! result=$(some_command); then
    echo "Error: command substitution failed" >&2
    exit 1
fi
```

This makes the intended behavior clear regardless of subtle option-inheritance rules.

---

## 10. Enabling and Disabling `set -e`

Enable it:

```bash
set -e
```

Disable it:

```bash
set +e
```

Enable it again:

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

An explicit conditional is often easier to understand:

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

1. Strict safety options are enabled.
2. The `ERR` trap reports the line number for an unexpected error.
3. Two command-line arguments are validated.
4. The source is validated as a regular file.
5. `if` directly checks the result of `cp`.
6. Success goes to stdout and failure goes to stderr.
7. The script returns an accurate status.

Check its syntax:

```bash
bash -n safe_backup.sh
```

Debug its execution:

```bash
bash -x safe_backup.sh source.txt backup.txt
```

---

## 12. Common Mistakes

### Mistake 1: Assuming Every Failure Causes an Exit

`set -e` is context-sensitive. Important exceptions involve `if`, `!`, `&&`, `||`, loop conditions, and pipelines.

### Mistake 2: Treating `set -e` as Complete Error Handling

`set -e` does not automatically provide a descriptive message, cleanup, retry, recovery, or rollback.

### Mistake 3: Forgetting `pipefail`

```bash
set -e
command1 | command2
```

An earlier pipeline failure may be hidden. Use `set -o pipefail` when the pipeline should fail if an earlier command fails.

### Mistake 4: Treating an Expected Nonzero Result as an Unexpected Failure

For example, `grep` returns status `1` for “no match,” which may be expected in some workflows.

### Mistake 5: Providing No Error Context

Automatic termination does not explain what the script was trying to do. Send descriptive messages to stderr for critical operations.

### Mistake 6: Forgetting Cleanup

Use `trap` for temporary-resource cleanup:

```bash
temp_file=$(mktemp)
trap 'rm -f -- "$temp_file"' EXIT
```

The `EXIT` trap runs when the shell exits normally or because of most script errors.

---

## 13. Practice Lab

Create `set_e_demo.sh` that:

1. Uses `set -Eeuo pipefail`.
2. Uses an `ERR` trap to print a failed line number to stderr.
3. Receives a source filename through `$1`.
4. Validates a missing argument and missing file.
5. Searches the file for the word `ERROR`.
6. Handles “no match” as an expected result.
7. Handles a real `grep` error as failure.
8. Returns `exit 0` on success.

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

Create test data:

```bash
echo "INFO: application started" > application.log
bash set_e_demo.sh application.log
```

Add a matching line:

```bash
echo "ERROR: database unavailable" >> application.log
bash set_e_demo.sh application.log
```

Test a missing file:

```bash
bash set_e_demo.sh missing.log
echo "$?"
```

---

## 14. Quick Reference

| Syntax | Meaning |
|---|---|
| `set -e` | Enable exit behavior for certain unhandled failures. |
| `set +e` | Disable the `-e` option. |
| `set -u` | Treat the use of an unset variable as an error. |
| `set -o pipefail` | Expose failures from earlier pipeline commands. |
| `set -E` | Improve inheritance of the `ERR` trap. |
| `set -Eeuo pipefail` | A common strict safety combination. |
| `$?` | Status of the most recently completed command. |
| `exit N` | End a script with status `N`. |
| `return N` | End a function with status `N`. |
| `if command; then` | Run `then` when the command returns `0`. |
| `if ! command; then` | Run `then` when the command returns nonzero. |

---

## 15. Final Summary

```bash
set -e
```

Practical meaning:

> If an unhandled command fails, terminate the script instead of continuing.

Remember:

- Exiting is not guaranteed for every nonzero result.
- Behavior depends on the command's syntactic context.
- Pipelines often require `pipefail`.
- Expected failures should be handled explicitly.
- Clear error messages should be sent to stderr.
- `trap` is useful for reporting and cleanup.

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

> Do not depend on `set -e` alone. Validate critical operations, provide clear errors, clean up resources, and return accurate exit statuses.

