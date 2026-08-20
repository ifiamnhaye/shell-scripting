# Bash `echo` and `printf` — Complete Study Notes

## Table of Contents

1. [Output Commands](#1-output-commands)
2. [The echo Command](#2-the-echo-command)
3. [Quoting and Variables](#3-quoting-and-variables)
4. [The printf Command](#4-the-printf-command)
5. [Format Specifiers](#5-format-specifiers)
6. [Escape Sequences](#6-escape-sequences)
7. [Printing Arrays](#7-printing-arrays)
8. [Rows, Columns, and Separators](#8-rows-columns-and-separators)
9. [Field Width and Precision](#9-field-width-and-precision)
10. [Standard Output and Standard Error](#10-standard-output-and-standard-error)
11. [echo vs printf](#11-echo-vs-printf)
12. [Common Mistakes](#12-common-mistakes)
13. [Practice Scripts](#13-practice-scripts)
14. [Quick Reference](#14-quick-reference)

---

## 1. Output Commands

Bash scripts use output commands to display:

- Messages
- Variable values
- Errors and warnings
- Lists and arrays
- Formatted reports

The two common commands are:

```bash
echo
printf
```

Both display output, but `printf` offers more precise formatting.

---

## 2. The echo Command

`echo` prints its arguments and normally adds a newline.

### Simple text

```bash
echo "Hello, DevOps!"
```

Output:

```text
Hello, DevOps!
```

### Variable value

```bash
name="Khalid"
echo "$name"
```

### Text and variables

```bash
name="Khalid"
course="Bash Scripting"

echo "Student: $name"
echo "Course: $course"
```

### Blank line

```bash
echo
```

### Output without a final newline

Bash supports:

```bash
echo -n "Loading..."
```

A more predictable form is:

```bash
printf '%s' "Loading..."
```

### Escape sequences with echo

Bash `echo -e` can interpret escapes:

```bash
echo -e "Name:\tKhalid\nCourse:\tBash"
```

Because `echo` option and escape behavior can vary between shells, use `printf` when exact formatting matters:

```bash
printf 'Name:\t%s\nCourse:\t%s\n' "Khalid" "Bash"
```

---

## 3. Quoting and Variables

### Double quotes

Double quotes allow variable expansion and preserve spaces:

```bash
fruit="red cherry"
echo "$fruit"
```

Output:

```text
red cherry
```

### Single quotes

Single quotes prevent variable expansion:

```bash
name="Ali"
echo 'Hello, $name'
```

Output:

```text
Hello, $name
```

### Recommended quoting

```bash
echo "$message"
printf '%s\n' "$message"
```

Unquoted variable expansions may undergo word splitting and pathname expansion.

---

## 4. The printf Command

`printf` means **print formatted**.

Syntax:

```bash
printf 'FORMAT' ARGUMENTS
```

Example:

```bash
printf '%s\n' "Hello"
```

Unlike `echo`, `printf` does not automatically add a newline.

Without newline:

```bash
printf '%s' "Hello"
```

With newline:

```bash
printf '%s\n' "Hello"
```

### Understanding `'%s\n'`

| Part | Meaning |
|---|---|
| `%` | Starts a format specification |
| `s` | Print the supplied value as a string |
| `\n` | Start a new line |

Example:

```bash
printf '%s\n' "apple"
```

`%s` is replaced by `apple`, and `\n` moves to the next line.

### Format reuse

```bash
printf '%s\n' "apple" "banana" "red cherry"
```

Output:

```text
apple
banana
red cherry
```

The format is reused once for each supplied value.

---

## 5. Format Specifiers

A percent sign begins a format specifier.

| Specifier | Meaning | Example |
|---|---|---|
| `%s` | String | `printf '%s\n' "Hello"` |
| `%d` | Decimal integer | `printf '%d\n' 25` |
| `%i` | Integer | `printf '%i\n' 25` |
| `%f` | Floating-point number | `printf '%f\n' 3.14` |
| `%.2f` | Two decimal places | `printf '%.2f\n' 3.14159` |
| `%x` | Lowercase hexadecimal | `printf '%x\n' 255` |
| `%X` | Uppercase hexadecimal | `printf '%X\n' 255` |
| `%o` | Octal | `printf '%o\n' 8` |
| `%c` | First character | `printf '%c\n' "Apple"` |
| `%b` | Interpret escapes in an argument | `printf '%b' 'A\nB\n'` |
| `%q` | Shell-escaped form; Bash-specific | `printf '%q\n' "red cherry"` |
| `%%` | Literal percent sign | `printf '80%%\n'` |

### Multiple placeholders

```bash
printf 'Name: %s | Age: %d\n' "Khalid" 25
```

Output:

```text
Name: Khalid | Age: 25
```

### Percentage

```bash
printf 'Score: %d%%\n' 80
```

Output:

```text
Score: 80%
```

`%d` prints `80` and `%%` prints a literal percent sign.

---

## 6. Escape Sequences

| Sequence | Meaning |
|---|---|
| `\n` | Newline |
| `\t` | Horizontal tab |
| `\\` | Literal backslash |
| `\r` | Carriage return |
| `\b` | Backspace |

### Newlines

```bash
printf 'Line 1\nLine 2\n'
```

### Tabs

```bash
printf 'Name\tCourse\n'
printf 'Ali\tBash\n'
```

Tabs are simple, but fixed-width fields are better when values have different lengths.

---

## 7. Printing Arrays

Create an array:

```bash
items=("apple" "banana" "red cherry")
```

### First element

```bash
echo "${items[0]}"
```

`"${items}"` also refers to the first element.

### All elements on one row

```bash
echo "${items[@]}"
```

Output:

```text
apple banana red cherry
```

### One element per line

```bash
printf '%s\n' "${items[@]}"
```

Output:

```text
apple
banana
red cherry
```

### Why quotes matter

Quoted `"${items[@]}"` passes every array element separately while preserving spaces inside `"red cherry"`.

### Element count

```bash
printf 'Total items: %d\n' "${#items[@]}"
```

### Indexes and values

```bash
for index in "${!items[@]}"
do
    printf 'Index %d: %s\n' "$index" "${items[index]}"
done
```

---

## 8. Rows, Columns, and Separators

### Space-separated row

```bash
echo "${items[@]}"
```

Using `printf`:

```bash
printf '%s ' "${items[@]}"
printf '\n'
```

The first command includes a trailing space after the last item.

### One item per line

```bash
printf '%s\n' "${items[@]}"
```

### Single-character separator

Quoted `"${items[*]}"` joins elements using the first character of `IFS`:

```bash
(
    IFS=','
    printf '%s\n' "${items[*]}"
)
```

Output:

```text
apple,banana,red cherry
```

The parentheses create a subshell, so the temporary `IFS` value does not affect the surrounding shell.

### Comma followed by a space

A loop gives precise multi-character separation:

```bash
for (( index = 0; index < ${#items[@]}; index++ ))
do
    (( index > 0 )) && printf ', '
    printf '%s' "${items[index]}"
done

printf '\n'
```

Output:

```text
apple, banana, red cherry
```

### Two-column output

```bash
printf '%-12s %s\n' "ITEM" "STATUS"
printf '%-12s %s\n' "nginx" "active"
printf '%-12s %s\n' "ssh" "inactive"
```

---

## 9. Field Width and Precision

### Right-aligned string

```bash
printf '|%10s|\n' "Bash"
```

Output:

```text
|      Bash|
```

### Left-aligned string

```bash
printf '|%-10s|\n' "Bash"
```

Output:

```text
|Bash      |
```

### Leading zeros

```bash
printf '%04d\n' 7
```

Output:

```text
0007
```

### Decimal precision

```bash
printf 'Price: %.2f\n' 19.995
```

### Limit string length

```bash
printf '%.5s\n' "Bash Scripting"
```

This prints at most five characters.

---

## 10. Standard Output and Standard Error

Normal messages go to standard output:

```bash
echo "Operation completed."
printf '%s\n' "Operation completed."
```

Error messages should go to standard error:

```bash
echo "Error: file not found." >&2
printf 'Error: %s\n' "file not found" >&2
```

Overwrite a file:

```bash
printf '%s\n' "Backup completed." > output.log
```

Append to a file:

```bash
printf '%s\n' "Backup completed." >> output.log
```

---

## 11. echo vs printf

| Feature | `echo` | `printf` |
|---|---|---|
| Simple messages | Excellent | Good |
| Automatic newline | Yes | No |
| Exact formatting | Limited | Excellent |
| Placeholders | No | Yes |
| Aligned columns | No | Yes |
| Decimal precision | No | Yes |
| Behavior across shells | Can vary for options/escapes | More predictable |
| Array in one row | Easy | Easy |
| Array one item per line | Usually needs a loop | Direct |

### Recommended rule

Use `echo` for simple messages:

```bash
echo "Backup completed."
```

Use `printf` for:

- Exact formatting
- Arrays
- Numbers and percentages
- Columns
- Controlled newlines
- Values that may begin with `-`

---

## 12. Common Mistakes

### Missing newline

```bash
printf '%s' "Hello"
```

Add `\n` when needed:

```bash
printf '%s\n' "Hello"
```

### User data used as the format

Avoid:

```bash
printf "$user_input"
```

Use a fixed format:

```bash
printf '%s\n' "$user_input"
```

This prevents percent signs or backslashes in data from being treated as formatting instructions.

### Unquoted array

Avoid:

```bash
printf '%s\n' ${items[@]}
```

Use:

```bash
printf '%s\n' "${items[@]}"
```

### Only the first array element

```bash
echo "${items}"
```

For all elements:

```bash
echo "${items[@]}"
```

### Wrong placeholder

Use `%s` for text and `%d` for decimal integers.

### Depending on echo escape behavior

Prefer this:

```bash
printf 'Line 1\nLine 2\n'
```

---

## 13. Practice Scripts

### Script 1: Basic output

**Create: `echo_and_printf_demo.sh`**

```bash
#!/bin/bash

# Title: echo and printf Demo
# Purpose: Compare simple and formatted output.

student_name="Khalid"
score=85

echo "Student: $student_name"
printf 'Score: %d%%\n' "$score"

exit 0
```

### Script 2: Array output

**Create: `display_fruit_array.sh`**

```bash
#!/bin/bash

# Title: Display Fruit Array
# Purpose: Print an array in one row and one item per line.

fruits=("apple" "banana" "red cherry")

echo "One row:"
echo "${fruits[@]}"

echo
echo "One item per line:"
printf '%s\n' "${fruits[@]}"

exit 0
```

### Script 3: Numbered items

**Create: `numbered_fruit_list.sh`**

```bash
#!/bin/bash

# Title: Numbered Fruit List
# Purpose: Display fruits with human-friendly item numbers.

fruits=("apple" "banana" "red cherry")
item_number=1

for fruit in "${fruits[@]}"
do
    printf 'Item %d: %s\n' "$item_number" "$fruit"
    item_number=$((item_number + 1))
done

exit 0
```

### Script 4: Formatted table

**Create: `service_status_report.sh`**

```bash
#!/bin/bash

# Title: Service Status Report
# Purpose: Display service names and statuses in aligned columns.

services=("nginx" "ssh" "cron")
statuses=("active" "active" "inactive")

printf '%-15s %-10s\n' "SERVICE" "STATUS"
printf '%-15s %-10s\n' "---------------" "----------"

for index in "${!services[@]}"
do
    printf '%-15s %-10s\n' \
        "${services[index]}" \
        "${statuses[index]}"
done

exit 0
```

Check syntax:

```bash
bash -n echo_and_printf_demo.sh
bash -n display_fruit_array.sh
bash -n numbered_fruit_list.sh
bash -n service_status_report.sh
```

---

## 14. Quick Reference

| Requirement | Command |
|---|---|
| Simple message | `echo "Hello"` |
| Blank line | `echo` or `printf '\n'` |
| String with newline | `printf '%s\n' "$value"` |
| String without newline | `printf '%s' "$value"` |
| Integer | `printf '%d\n' "$number"` |
| Percentage | `printf '%d%%\n' "$score"` |
| Two decimal places | `printf '%.2f\n' "$value"` |
| Array in one row | `echo "${items[@]}"` |
| Array on separate lines | `printf '%s\n' "${items[@]}"` |
| Array count | `printf '%d\n' "${#items[@]}"` |
| Error to stderr | `printf 'Error: %s\n' "$message" >&2` |
| Left-aligned field | `printf '%-15s\n' "$value"` |
| Literal percent sign | `printf '80%%\n'` |
| Append to a file | `printf '%s\n' "$message" >> file.log` |

## Final Summary

Simple output:

```bash
echo "Backup completed."
```

Controlled output:

```bash
printf 'Backup: %s | Status: %s\n' "$backup_file" "completed"
```

Array elements on separate lines:

```bash
printf '%s\n' "${items[@]}"
```

Meaning:

```text
printf          → formatted output
%               → starts a format specification
%s              → prints the next value as a string
\n              → starts a new line
"${items[@]}"  → passes every array element separately
```

> **Golden rule:** Keep the format string fixed and pass values as separate, quoted arguments.

