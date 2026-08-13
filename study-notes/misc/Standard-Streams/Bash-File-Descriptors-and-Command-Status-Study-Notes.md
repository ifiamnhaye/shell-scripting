# Bash File Descriptors and Command Status — Study Notes

## Table of Contents

- [1. Overview](#1-overview)
- [2. What Is a File Descriptor?](#2-what-is-a-file-descriptor)
- [3. Standard File Descriptors](#3-standard-file-descriptors)
- [4. File-Descriptor Examples](#4-file-descriptor-examples)
- [5. What Is a Command Status?](#5-what-is-a-command-status)
- [6. File Descriptor vs Command Status](#6-file-descriptor-vs-command-status)
- [7. The Same Number Can Have Different Meanings](#7-the-same-number-can-have-different-meanings)
- [8. Complete Script Example](#8-complete-script-example)
- [9. Common Mistakes](#9-common-mistakes)
- [10. Quick Reference](#10-quick-reference)
- [11. Practice Lab](#11-practice-lab)
- [12. Summary](#12-summary)

---

## 1. Overview

File descriptors and command statuses both use numbers, but they solve completely different problems:

```text
File descriptor = Where does the data travel?
Command status  = How did the command finish?
```

- A **file descriptor** identifies an open input/output resource.
- A **command status** reports whether a completed command succeeded or failed.

---

## 2. What Is a File Descriptor?

A **file descriptor** is a small integer that a process uses as a reference to an open input/output resource.

In simple words:

> A file descriptor is a numeric handle that tells a command where to receive input or send output.

A file descriptor is not the file itself. It may refer to:

- A terminal
- A regular file
- A pipe
- A socket
- Another input/output resource

File descriptors exist inside a running process while their associated resources remain open.

---

## 3. Standard File Descriptors

Every Bash command normally begins with three standard file descriptors:

| Number | Name | Purpose |
|---:|---|---|
| `0` | stdin | Provides input to the command. |
| `1` | stdout | Carries normal output from the command. |
| `2` | stderr | Carries error messages from the command. |

Default flow:

```text
Keyboard ── stdin (0) ──> Command
Command  ── stdout (1) ─> Terminal
Command  ── stderr (2) ─> Terminal
```

A **stream** is the logical path through which data flows. A stream is not a folder.

---

## 4. File-Descriptor Examples

### 4.1 Redirect stdout

```bash
echo "Hello" 1> output.log
```

Explanation:

- `echo` normally writes to stdout.
- `1` identifies stdout.
- `>` redirects that output to `output.log`.

Because stdout is the default output stream, `1` may be omitted:

```bash
echo "Hello" > output.log
```

### 4.2 Redirect stderr

```bash
ls /missing 2> error.log
```

Explanation:

- `ls` cannot access `/missing`.
- The error is produced on stderr.
- `2>` sends stderr to `error.log`.

### 4.3 Send an `echo` message to stderr

```bash
echo "Error: file not found" >&2
```

`echo` normally writes to stdout. `>&2` sends its stdout to stderr's current destination.

This can be written explicitly as:

```bash
echo "Error: file not found" 1>&2
```

These are equivalent:

```bash
>&2
1>&2
```

### 4.4 Send stdout and stderr to one file

```bash
command > all.log 2>&1
```

Bash processes redirections from left to right:

1. `> all.log` sends stdout to `all.log`.
2. `2>&1` sends stderr to stdout's current destination.
3. Therefore, stdout and stderr both go to `all.log`.

Bash also supports this shorter form:

```bash
command &> all.log
```

### 4.5 Use a custom file descriptor

```bash
exec 3> custom.log
echo "Custom message" >&3
exec 3>&-
```

Explanation:

- `exec 3> custom.log` opens `custom.log` on file descriptor `3`.
- `>&3` sends the message through descriptor `3`.
- `exec 3>&-` closes descriptor `3`.

---

## 5. What Is a Command Status?

A **command status**, also called an **exit status** or **return status**, is a number produced when a command finishes.

The usual convention is:

```text
0       = success
nonzero = failure, warning, or another special result
```

Shell statuses are normally represented in the range `0` through `255`.

### Check the last status

```bash
ls /missing
echo "$?"
```

`$?` contains the status returned by the most recently executed command.

The failed `ls` command may return:

```text
2
```

The exact meanings of nonzero statuses are defined by each command.

### Set a script's status

```bash
exit 0
```

This ends the script and reports success.

```bash
exit 1
```

This ends the script and reports a general failure.

### Save the status immediately

Every subsequent command replaces `$?`. Save it before running another command:

```bash
cp source.txt backup.txt
status=$?
echo "cp returned: $status"
```

---

## 6. File Descriptor vs Command Status

| Feature | File Descriptor | Command Status |
|---|---|---|
| Purpose | Identifies an input/output channel | Reports how a command finished |
| Main question | Where should data go? | Did the command succeed or fail? |
| Common values | `0`, `1`, `2`, and custom descriptors | Usually `0` through `255` |
| Used with | Redirection operators | `$?`, `if`, `exit`, and `return` |
| Examples | `2> error.log`, `>&2` | `echo "$?"`, `exit 1` |
| Created or used | While a process has a resource open | When a command finishes |
| Meaning of `0` | stdin | Successful completion |
| Meaning of `1` | stdout | A nonzero result or general failure by convention |
| Meaning of `2` | stderr | A command-specific nonzero result |

The numbers look similar, but the two systems are unrelated.

---

## 7. The Same Number Can Have Different Meanings

Consider:

```bash
ls /missing 2> error.log
echo "$?"
```

There are two separate uses of the number `2`:

### In the redirection

```bash
2> error.log
```

Here, `2` is the stderr **file descriptor**. It answers:

> Where should the error message go?

### In the command result

```bash
echo "$?"
```

If this prints `2`, that `2` is the **exit status** returned by `ls`. It answers:

> How did the `ls` command finish?

The exit status happened to be `2`; it does not mean stderr.

Another comparison:

```bash
exit 2
```

Here, `2` is a command status.

```bash
echo "Error" >&2
```

Here, `2` is a file descriptor.

---

## 8. Complete Script Example

```bash
#!/bin/bash

# Purpose: Copy a file and handle errors.

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
| `2> error.log` | Sends error messages produced by `cp` through file descriptor `2` into `error.log`. |
| `if cp ...; then` | Checks the command status returned by `cp` directly. |
| `status=$?` | Immediately saves the failure status returned by `cp`. |
| `>&2` | Sends the custom error message to stderr. |
| `exit 0` | Ends the script successfully. |
| `exit "$status"` | Ends the script using the failure status returned by `cp`. |

This example uses file descriptors to control **where messages go** and command statuses to control **what the script does next**.

---

## 9. Common Mistakes

### Mistake 1: Thinking `$?` is a file descriptor

```bash
echo "$?"
```

`$?` is the previous command's status. It is not an input/output channel.

### Mistake 2: Thinking `2>` means status 2

```bash
command 2> error.log
```

The `2` identifies stderr. This redirection does not set the command's status to `2`.

### Mistake 3: Checking `$?` too late

Incorrect:

```bash
cp source.txt backup.txt
echo "Copy attempted"
echo "$?"
```

The final `echo "$?"` reports the status of the first `echo`, not `cp`.

Correct:

```bash
cp source.txt backup.txt
status=$?
echo "cp returned: $status"
```

### Mistake 4: Using `$?` when `if` can check directly

Less clear:

```bash
cp source.txt backup.txt

if [[ "$?" -eq 0 ]]; then
    echo "Copy completed"
fi
```

Preferred:

```bash
if cp source.txt backup.txt; then
    echo "Copy completed"
fi
```

### Mistake 5: Confusing `>&2` with `>2`

```bash
echo "Error" >2
```

This creates or overwrites a file named `2`.

```bash
echo "Error" >&2
```

This sends the message to stderr's current destination.

### Mistake 6: Reversing redirection order

These commands are not always equivalent:

```bash
command > all.log 2>&1
command 2>&1 > all.log
```

In the first command, both streams go to `all.log`.

In the second command, stderr is first connected to stdout's original destination, and then only stdout is moved to `all.log`. Redirections are processed from left to right.

---

## 10. Quick Reference

### File descriptors and redirection

| Syntax | Meaning |
|---|---|
| `0` | stdin |
| `1` | stdout |
| `2` | stderr |
| `> file` | Send stdout to a file and overwrite it. |
| `>> file` | Append stdout to a file. |
| `2> file` | Send stderr to a file and overwrite it. |
| `2>> file` | Append stderr to a file. |
| `>&2` | Send stdout to stderr's current destination. |
| `2>&1` | Send stderr to stdout's current destination. |
| `&> file` | Send stdout and stderr to one file. |

### Command status

| Syntax | Meaning |
|---|---|
| `$?` | Status of the most recently completed command |
| `0` | Success |
| Nonzero | Failure or another command-defined result |
| `exit N` | End a script with status `N` |
| `return N` | End a function with status `N` |
| `if command; then` | Run the `then` block when the command returns status `0` |
| `if ! command; then` | Run the `then` block when the command returns a nonzero status |

---

## 11. Practice Lab

Create `fd_status_demo.sh` that:

1. Accepts a source path as `$1`.
2. Sends a usage message to stderr when `$1` is missing.
3. Uses `cp` to copy the source to `/tmp/source-backup`.
4. Sends `cp` errors to `error.log`.
5. Prints a success message to stdout when the copy succeeds.
6. Saves and prints the status returned by `cp` when it fails.
7. Exits with `0` on success and the saved `cp` status on failure.

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

Remember this distinction:

```text
File descriptor = where input or output travels
Command status  = whether and how a command completed
```

Examples:

```bash
echo "Error" >&2
```

The `2` is a file descriptor.

```bash
exit 2
```

The `2` is a command status.

Final rule:

> File descriptors manage input and output. Command statuses report success or failure.
