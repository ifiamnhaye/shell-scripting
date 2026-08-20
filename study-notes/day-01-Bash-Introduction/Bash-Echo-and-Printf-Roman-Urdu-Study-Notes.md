# Bash `echo` aur `printf` — Roman Urdu Study Notes

## Table of Contents

1. [Output Commands ka Maqsad](#1-output-commands-ka-maqsad)
2. [echo Command](#2-echo-command)
3. [Quoting aur Variables](#3-quoting-aur-variables)
4. [printf Command](#4-printf-command)
5. [Format Specifiers](#5-format-specifiers)
6. [Escape Sequences](#6-escape-sequences)
7. [Arrays Print Karna](#7-arrays-print-karna)
8. [Rows, Columns aur Separators](#8-rows-columns-aur-separators)
9. [Field Width aur Precision](#9-field-width-aur-precision)
10. [Standard Output aur Standard Error](#10-standard-output-aur-standard-error)
11. [echo vs printf](#11-echo-vs-printf)
12. [Common Mistakes](#12-common-mistakes)
13. [Practice Scripts](#13-practice-scripts)
14. [Quick Reference](#14-quick-reference)

---

## 1. Output Commands ka Maqsad

Bash scripts output commands ko in kaamon ke liye use karti hain:

- Messages display karna
- Variables ki values dikhana
- Errors aur warnings print karna
- Lists aur arrays show karna
- Formatted reports aur tables banana
- Output ko files mein redirect karna

Do common output commands hain:

```bash
echo
printf
```

Dono text display karte hain, lekin `printf` zyada controlled aur predictable formatting deta hai.

---

## 2. echo Command

`echo` apne arguments print karta hai aur aam tor par end mein newline automatically add karta hai.

### Simple text print karna

```bash
echo "Hello, DevOps!"
```

Output:

```text
Hello, DevOps!
```

### Variable ki value print karna

```bash
name="Khalid"
echo "$name"
```

Output:

```text
Khalid
```

### Text aur variables ko combine karna

```bash
name="Khalid"
course="Bash Scripting"

echo "Student: $name"
echo "Course: $course"
```

### Blank line print karna

```bash
echo
```

### Final newline ke baghair print karna

Bash mein `-n` newline ko rokta hai:

```bash
echo -n "Loading..."
```

Predictable alternative:

```bash
printf '%s' "Loading..."
```

### `echo -e` aur escape sequences

Bash mein `-e` backslash escapes interpret kar sakta hai:

```bash
echo -e "Name:\tKhalid\nCourse:\tBash"
```

Lekin `echo` ke options aur escapes ka behavior different shells mein change ho sakta hai. Exact formatting ke liye `printf` better hai:

```bash
printf 'Name:\t%s\nCourse:\t%s\n' "Khalid" "Bash"
```

---

## 3. Quoting aur Variables

### Double quotes

Double quotes variable expansion allow karti hain aur spaces ko preserve karti hain:

```bash
fruit="red cherry"
echo "$fruit"
```

Output:

```text
red cherry
```

### Single quotes

Single quotes variable expansion ko rok deti hain:

```bash
name="Ali"
echo 'Hello, $name'
```

Output:

```text
Hello, $name
```

### Safe quoting

Recommended:

```bash
echo "$message"
printf '%s\n' "$message"
```

Unquoted variable word splitting aur pathname expansion ka shikar ho sakta hai. Is liye values ko aam tor par double quotes mein use karein.

---

## 4. printf Command

`printf` ka meaning **print formatted** hai.

Basic syntax:

```bash
printf 'FORMAT' ARGUMENTS
```

Example:

```bash
printf '%s\n' "Hello"
```

Output:

```text
Hello
```

`echo` ke baraks, `printf` newline automatically add nahi karta.

Newline ke baghair:

```bash
printf '%s' "Hello"
```

Newline ke saath:

```bash
printf '%s\n' "Hello"
```

### `'%s\n'` ki explanation

| Part | Meaning |
|---|---|
| `%` | Format specification start karta hai |
| `s` | Value ko string ki tarah print karta hai |
| `\n` | Nayi line start karta hai |

Example:

```bash
printf '%s\n' "apple"
```

Yahan `%s` ki jagah `apple` print hota hai aur `\n` cursor ko next line par le jata hai.

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

Agar arguments placeholders se zyada hon, `printf` format ko dobara use karta hai:

```text
%s → apple
%s → banana
%s → red cherry
```

---

## 5. Format Specifiers

Percent sign `%` format specifier ko start karta hai.

| Specifier | Meaning | Example |
|---|---|---|
| `%s` | String print karo | `printf '%s\n' "Hello"` |
| `%d` | Decimal integer print karo | `printf '%d\n' 25` |
| `%i` | Integer print karo | `printf '%i\n' 25` |
| `%f` | Floating-point number print karo | `printf '%f\n' 3.14` |
| `%.2f` | Two decimal places | `printf '%.2f\n' 3.14159` |
| `%x` | Lowercase hexadecimal | `printf '%x\n' 255` |
| `%X` | Uppercase hexadecimal | `printf '%X\n' 255` |
| `%o` | Octal number | `printf '%o\n' 8` |
| `%c` | Pehla character | `printf '%c\n' "Apple"` |
| `%b` | Argument ke escapes interpret karo | `printf '%b' 'A\nB\n'` |
| `%q` | Shell-escaped representation; Bash-specific | `printf '%q\n' "red cherry"` |
| `%%` | Literal percent sign | `printf '80%%\n'` |

### Multiple placeholders

```bash
printf 'Name: %s | Age: %d\n' "Khalid" 25
```

Output:

```text
Name: Khalid | Age: 25
```

- Pehla `%s` value `Khalid` receive karta hai.
- `%d` value `25` receive karta hai.

### Percentage print karna

```bash
printf 'Score: %d%%\n' 80
```

Output:

```text
Score: 80%
```

- `%d`, `80` print karta hai.
- `%%`, literal `%` print karta hai.

---

## 6. Escape Sequences

Escape sequences output ki layout control karti hain.

| Sequence | Meaning |
|---|---|
| `\n` | Newline |
| `\t` | Horizontal tab |
| `\\` | Literal backslash |
| `\r` | Carriage return |
| `\b` | Backspace |

### Newline

```bash
printf 'Line 1\nLine 2\n'
```

Output:

```text
Line 1
Line 2
```

### Tab

```bash
printf 'Name\tCourse\n'
printf 'Ali\tBash\n'
```

Tabs simple hain, lekin different length values mein alignment change ho sakti hai. Reports ke liye fixed-width fields better hain.

---

## 7. Arrays Print Karna

Array create karein:

```bash
items=("apple" "banana" "red cherry")
```

### Pehla element

```bash
echo "${items[0]}"
```

Yeh bhi first element ko refer karta hai:

```bash
echo "${items}"
```

### Tamam elements aik row mein

```bash
echo "${items[@]}"
```

Output:

```text
apple banana red cherry
```

### Har element alag line par

```bash
printf '%s\n' "${items[@]}"
```

Output:

```text
apple
banana
red cherry
```

### Quotes kyun important hain?

Quoted form:

```bash
"${items[@]}"
```

har array element ko alag argument rakhta hai aur `"red cherry"` ke andar space preserve karta hai.

### Total elements

```bash
printf 'Total items: %d\n' "${#items[@]}"
```

Output:

```text
Total items: 3
```

### Index aur value print karna

```bash
for index in "${!items[@]}"
do
    printf 'Index %d: %s\n' "$index" "${items[index]}"
done
```

Output:

```text
Index 0: apple
Index 1: banana
Index 2: red cherry
```

---

## 8. Rows, Columns aur Separators

### Space-separated row

Beginner-friendly command:

```bash
echo "${items[@]}"
```

`printf` ke saath:

```bash
printf '%s ' "${items[@]}"
printf '\n'
```

Pehla command last item ke baad bhi aik space print karega, jo screen output mein aam tor par problem nahi hoti.

### Har item alag line par

```bash
printf '%s\n' "${items[@]}"
```

### Single-character separator

Double quotes ke andar `"${items[*]}"` tamam elements ko `IFS` ke first character se join karta hai:

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

Parentheses subshell banati hain, is liye temporary `IFS` change surrounding shell ko affect nahi karta.

### Comma aur space separator

Multi-character separator accurately add karne ke liye loop use karein:

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

Output:

```text
ITEM         STATUS
nginx        active
ssh          inactive
```

---

## 9. Field Width aur Precision

### Right-aligned string

```bash
printf '|%10s|\n' "Bash"
```

Output:

```text
|      Bash|
```

`%10s` kam az kam 10 characters ka field banata aur string ko right-align karta hai.

### Left-aligned string

```bash
printf '|%-10s|\n' "Bash"
```

Output:

```text
|Bash      |
```

Minus sign left alignment select karta hai.

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

`%.2f` number ko two decimal places tak format karta hai.

### String ki maximum length

```bash
printf '%.5s\n' "Bash Scripting"
```

`%.5s` maximum five characters print karta hai.

---

## 10. Standard Output aur Standard Error

Normal messages standard output par jate hain:

```bash
echo "Operation completed."
printf '%s\n' "Operation completed."
```

Error messages standard error par bhejne chahiye:

```bash
echo "Error: file not found." >&2
printf 'Error: %s\n' "file not found" >&2
```

Output ko file mein overwrite karna:

```bash
printf '%s\n' "Backup completed." > output.log
```

Output append karna:

```bash
printf '%s\n' "Backup completed." >> output.log
```

---

## 11. echo vs printf

| Feature | `echo` | `printf` |
|---|---|---|
| Simple messages | Bohat asaan | Asaan |
| Automatic newline | Haan | Nahi |
| Exact formatting | Limited | Bohat achi |
| Placeholders | Nahi | Haan |
| Aligned columns | Nahi | Haan |
| Decimal precision | Nahi | Haan |
| Different shells mein behavior | Options/escapes vary kar sakte hain | Zyada predictable |
| Array aik row mein | Asaan | Asaan |
| Array har item alag line par | Loop ki zaroorat ho sakti hai | Direct |

### Recommended rule

Simple message ke liye `echo` use karein:

```bash
echo "Backup completed."
```

`printf` use karein jab aap ko chahiye:

- Exact formatting
- Controlled newlines
- Arrays
- Numbers aur percentages
- Aligned columns
- Fixed format string
- Aisi value jo `-` se start ho sakti ho

---

## 12. Common Mistakes

### Mistake 1: printf se automatic newline expect karna

```bash
printf '%s' "Hello"
```

Newline chahiye to:

```bash
printf '%s\n' "Hello"
```

### Mistake 2: User input ko format string banana

Avoid:

```bash
printf "$user_input"
```

Agar input mein percent sign ya escape ho to `printf` usay formatting samajh sakta hai.

Correct:

```bash
printf '%s\n' "$user_input"
```

Format fixed rehta hai aur user data separate value hoti hai.

### Mistake 3: Array ko quote na karna

Less safe:

```bash
printf '%s\n' ${items[@]}
```

Correct:

```bash
printf '%s\n' "${items[@]}"
```

### Mistake 4: Poori array ke liye `${items}` use karna

```bash
echo "${items}"
```

Yeh sirf first element print karta hai. Tamam elements ke liye:

```bash
echo "${items[@]}"
```

### Mistake 5: `%s` aur `\n` ko same samajhna

- `%s` string argument ka placeholder hai.
- `\n` newline escape sequence hai.

### Mistake 6: Text ke liye `%d` use karna

Text ke liye `%s` use karein. `%d` decimal integer ke liye hai.

### Mistake 7: `echo -e` par portability ke liye depend karna

Predictable form:

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

Expected output:

```text
Student: Khalid
Score: 85%
```

### Script 2: Array display

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

### Script 3: Numbered array items

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

Expected output:

```text
Item 1: apple
Item 2: banana
Item 3: red cherry
```

### Script 4: Formatted service table

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

Syntax check:

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
| Blank line | `echo` ya `printf '\n'` |
| String with newline | `printf '%s\n' "$value"` |
| String without newline | `printf '%s' "$value"` |
| Integer | `printf '%d\n' "$number"` |
| Percentage | `printf '%d%%\n' "$score"` |
| Two decimal places | `printf '%.2f\n' "$value"` |
| Array aik row mein | `echo "${items[@]}"` |
| Har array item alag line par | `printf '%s\n' "${items[@]}"` |
| Array count | `printf '%d\n' "${#items[@]}"` |
| Error stderr par | `printf 'Error: %s\n' "$message" >&2` |
| Left-aligned field | `printf '%-15s\n' "$value"` |
| Literal percent sign | `printf '80%%\n'` |
| File mein append | `printf '%s\n' "$message" >> file.log` |

## Final Summary

Simple output:

```bash
echo "Backup completed."
```

Controlled output:

```bash
printf 'Backup: %s | Status: %s\n' "$backup_file" "completed"
```

Array items separate lines par:

```bash
printf '%s\n' "${items[@]}"
```

Is command ka meaning:

```text
printf          → formatted output print karta hai
%               → format specification start karta hai
%s              → next value ko string ki tarah print karta hai
\n              → nayi line start karta hai
"${items[@]}"  → har array element ko separately aur safely pass karta hai
```

> **Golden rule:** Format string ko fixed rakhein aur values ko separate, quoted arguments ki tarah pass karein.

