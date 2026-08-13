# Bash Study Notes: `return 1` vs `exit 1`

## Learning objective

Understand the practical difference between:

```bash
return 1
```

and:

```bash
exit 1
```

## Correct answer

> `return` leaves the function, while `exit` ends the entire script.

The number `1` represents a failure status. The command—`return` or `exit`—determines what stops.

---

## Exit-status basics

Every Bash command and function produces an exit status:

| Status | Meaning |
|---:|---|
| `0` | Success |
| Non-zero | Failure or another special condition |

The most recent exit status can be checked with:

```bash
echo $?
```

---

## Using `return 1`

`return 1` stops the current function and sends status `1` back to the function's caller.

```bash
#!/bin/bash

check_file()
{
    echo "File not found"
    return 1
}

check_file
echo "The script is still running"
```

Output:

```text
File not found
The script is still running
```

The function ends at `return 1`, but the script continues with the next command after the function call.

### Checking the returned status

```bash
check_file
echo $?
```

Output:

```text
File not found
1
```

### Handling the function's status with `if`

```bash
if check_file; then
    echo "The check succeeded"
else
    echo "The check failed" >&2
fi
```

Bash runs the `else` block because `check_file` returns status `1`.

---

## Using `exit 1`

`exit 1` terminates the entire script immediately and reports failure to the shell.

```bash
#!/bin/bash

check_file()
{
    echo "File not found"
    exit 1
}

check_file
echo "The script is still running"
```

Output:

```text
File not found
```

The last `echo` does not run because `exit 1` ends the complete script.

After running the script, its status can be checked from the terminal:

```bash
bash check-file.sh
echo $?
```

The result will be:

```text
1
```

---

## Comparison

| Command | Stops the function | Stops the entire script | Returned status |
|---|---:|---:|---:|
| `return 0` | Yes | No | Success |
| `return 1` | Yes | No | Failure |
| `exit 0` | Yes | Yes | Success |
| `exit 1` | Yes | Yes | Failure |

---

## Practical error-handling example

```bash
#!/bin/bash

create_backup()
{
    source_file=$1
    destination=$2

    if cp -- "$source_file" "$destination"; then
        echo "Backup completed"
        return 0
    else
        echo "Error: backup failed" >&2
        return 1
    fi
}

if ! create_backup "report.txt" "backup/report.txt"; then
    echo "The script is stopping because the backup failed" >&2
    exit 1
fi

echo "The script can continue with the next task"
```

### Flow

1. `create_backup` attempts to copy the file.
2. The function uses `return 0` when the copy succeeds.
3. It uses `return 1` when the copy fails.
4. The main script checks the function's status.
5. The main script decides whether it should continue or use `exit 1`.

This design makes the function reusable because the function reports its result while the main script controls the overall workflow.

---

## Common mistake

Incorrect understanding:

> `return 1` ends the entire script, while `exit 1` leaves only the function.

Correct understanding:

> `return 1` leaves the function, while `exit 1` ends the entire script.

---

## Important note

Normally, `return` is used inside a function:

```bash
my_function()
{
    return 1
}
```

Using `return` directly in a normally executed script produces an error:

```text
return: can only `return` from a function or sourced script
```

A sourced script is a special case because `return` may also be used to stop that sourced file without closing the current shell.

---

## Quick memory rule

> **Return from a function; exit from a script.**

## Practice task

Predict which messages will be printed:

```bash
#!/bin/bash

demo()
{
    echo "A"
    return 1
    echo "B"
}

echo "Start"
demo
echo "End"
```

### Answer

```text
Start
A
End
```

`echo "B"` does not run because `return 1` ends the function. However, `echo "End"` runs because the script itself was not terminated.
