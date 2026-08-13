# Bash `echo ... >&2` — English Study Notes

## Table of Contents

- [1. Command](#1-command)
- [2. Simple Meaning](#2-simple-meaning)
- [3. Command Breakdown](#3-command-breakdown)
- [4. How Does `>&2` Work?](#4-how-does-2-work)
- [5. Standard Streams](#5-standard-streams)
- [6. Why Does It Look the Same in the Terminal?](#6-why-does-it-look-the-same-in-the-terminal)
- [7. Save stdout and stderr Separately](#7-save-stdout-and-stderr-separately)
- [8. Complete Script Example](#8-complete-script-example)
- [9. Difference Between `>&2`, `2>`, `2>>`, and `&>`](#9-difference-between-2-2-2-and-)
- [10. Common Mistakes](#10-common-mistakes)
- [11. Practice Lab](#11-practice-lab)
- [12. Quick Summary](#12-quick-summary)

---

## 1. Command

```bash
echo "Error: source file does not exist." >&2
```

This command sends an error message to **standard error (`stderr`)** instead of standard output.

---

## 2. Simple Meaning

```text
Send this error message through the error-output stream, stderr.
```

`echo` normally writes its text to stdout. The `>&2` redirection makes its stdout use the current destination of stderr.

---

## 3. Command Breakdown

| Part | Name | Purpose |
|---|---|---|
| `echo` | Output command | Writes the supplied text as output. |
| `"Error: source file does not exist."` | Message | Tells the user that the source file is unavailable. |
| `>` | Redirection operator | Changes the destination of an output stream. |
| `&2` | File-descriptor reference | Refers to file descriptor `2`, which represents stderr. |
| `>&2` | Complete redirection | Sends stdout (`1`) to the current destination of stderr (`2`). |

---

## 4. How Does `>&2` Work?

The default output destination of `echo` is stdout, file descriptor `1`.

```bash
echo "Hello"
```

In this command, `Hello` is sent to stdout.

Now consider:

```bash
echo "Error: source file does not exist." >&2
```

Here, `>&2` means:

```text
Send file descriptor 1 to the current destination of file descriptor 2.
```

You can write the redirection explicitly as:

```bash
echo "Error: source file does not exist." 1>&2
```

These forms are equivalent:

```bash
>&2
1>&2
```

Important: `&2` does not mean a file named `2`. The ampersand tells Bash that `2` is a **file descriptor**.

---

## 5. Standard Streams

A Bash command starts with three standard streams:

| Number | Stream | Purpose |
|---:|---|---|
| `0` | stdin | The logical path through which input reaches a command |
| `1` | stdout | The logical path through which normal output leaves a command |
| `2` | stderr | The logical path through which error messages leave a command |

A stream is not a folder. A stream is a logical path through which data flows—like a pipe—carrying input or output from one place to another.

---

## 6. Why Does It Look the Same in the Terminal?

By default, both stdout and stderr are connected to the terminal.

Normal output:

```bash
echo "Backup completed"
```

Error output:

```bash
echo "Error: backup failed" >&2
```

Both messages normally appear on the screen, so they may look identical. The difference becomes clear when the streams are redirected.

---

## 7. Save stdout and stderr Separately

Consider a script containing:

```bash
echo "Backup started"
echo "Error: source file does not exist." >&2
```

### Save Only stdout

```bash
bash script.sh > output.log
```

Result:

- `Backup started` goes to `output.log`.
- The error message remains on the terminal.

### Save Only stderr

```bash
bash script.sh 2> error.log
```

Result:

- The normal message remains on the terminal.
- The error message goes to `error.log`.

### Save Both Streams Separately

```bash
bash script.sh > output.log 2> error.log
```

| Output | Destination |
|---|---|
| Normal messages | `output.log` |
| Error messages | `error.log` |

---

## 8. Complete Script Example

```bash
#!/bin/bash

# Purpose: Validate a source file.

source_file="${1:-}"

if [[ -z "$source_file" ]]; then
    echo "Usage: $0 SOURCE_FILE" >&2
    exit 1
fi

if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist: $source_file" >&2
    exit 1
fi

echo "Source file exists: $source_file"
exit 0
```

### Script Flow

1. `${1:-}` reads the first argument or supplies an empty value when it is missing.
2. `[[ -z "$source_file" ]]` checks whether a filename was provided.
3. A usage error is sent to stderr.
4. `[[ ! -f "$source_file" ]]` checks whether the path is not an existing regular file.
5. The missing-file message is sent to stderr.
6. `exit 1` reports failure.
7. If the file exists, the success message is sent to stdout.
8. `exit 0` reports successful completion.

### Run the Script

```bash
bash check_source.sh report.txt
```

Save errors to a file:

```bash
bash check_source.sh missing.txt 2> error.log
```

Display the saved error:

```bash
cat error.log
```

---

## 9. Difference Between `>&2`, `2>`, `2>>`, and `&>`

| Syntax | Purpose | Example Result |
|---|---|---|
| `>&2` | Sends stdout to the current destination of stderr | `echo "Error" >&2` sends the message through the error stream. |
| `2> file` | Sends stderr to a file and overwrites the file | `cmd 2> error.log` creates or replaces the error log. |
| `2>> file` | Appends stderr to the end of a file | `cmd 2>> error.log` preserves existing content. |
| `> file` | Sends only stdout to a file | `cmd > output.log` saves normal output. |
| `&> file` | Sends both stdout and stderr to a file | `cmd &> all.log` saves both output streams. |
| `> file 2>&1` | Sends stdout to a file, then sends stderr to stdout's current destination | Both streams go to `file`. |

---

## 10. Common Mistakes

### Mistake 1: Writing `>2`

```bash
echo "Error" >2
```

This does not redirect the message to stderr. It saves the output in a file named `2`.

Correct:

```bash
echo "Error" >&2
```

### Mistake 2: Treating `&>2` as `>&2`

```bash
echo "Error" &>2
```

This sends both stdout and stderr to a file named `2`.

However:

```bash
echo "Error" >&2
```

This sends the normal output of `echo` to stderr's destination.

### Mistake 3: Sending an Error Message to stdout

```bash
echo "Error: file missing"
```

This message goes to stdout. The script still runs, but separating normal output from errors later becomes difficult.

Better:

```bash
echo "Error: file missing" >&2
```

### Mistake 4: Reporting Success After an Error

```bash
echo "Error: file missing" >&2
exit 0
```

`exit 0` reports success. Use a nonzero status for failure:

```bash
echo "Error: file missing" >&2
exit 1
```

---

## 11. Practice Lab

### Task

Create `validate_file.sh` that:

1. Accepts the first command-line argument as a filename.
2. Sends a usage message to stderr when the argument is missing.
3. Sends an error message to stderr when the file is missing.
4. Sends a success message to stdout when the file is available.
5. Uses `exit 1` for failure and `exit 0` for success.

### Test Commands

Test a missing argument:

```bash
bash validate_file.sh
echo "$?"
```

Test a missing file and preserve the script's status:

```bash
bash validate_file.sh missing.txt 2> error.log
status=$?
cat error.log
echo "$status"
```

Test an existing file:

```bash
touch report.txt
bash validate_file.sh report.txt > output.log
cat output.log
```

Important: Check `$?` immediately after the command whose status you need, or save it in a variable before running another command. Every subsequent command replaces `$?`.

---

## 12. Quick Summary

```bash
echo "Error: source file does not exist." >&2
```

Simple meaning:

> Treat this message as error output and send it to stderr instead of normal output.

Remember:

```text
1 = stdout = normal output
2 = stderr = error output
>&2 = send stdout to stderr's current destination
```

A common error-handling pattern is:

```bash
if [[ ! -f "$source_file" ]]; then
    echo "Error: source file does not exist." >&2
    exit 1
fi
```

