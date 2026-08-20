# Bash Array Slicing — Complete Study Notes and Practice Problems

## Learning objectives

After completing these notes, you should be able to:

- create and display an indexed Bash array;
- understand array indexes;
- extract part of an array with slicing;
- keep or remove elements from the beginning or end;
- save a slice in a new array;
- slice command-line arguments;
- preserve values containing spaces;
- avoid common array-slicing mistakes;
- solve practical array problems in Bash scripts.

---

## 1. What is a Bash array?

A Bash array is a variable that can hold multiple values.

```bash
items=(apple banana mango orange grapes)
```

The array name is `items`, and it contains five elements.

| Index | Element |
|---:|---|
| `0` | `apple` |
| `1` | `banana` |
| `2` | `mango` |
| `3` | `orange` |
| `4` | `grapes` |

Bash indexed arrays normally begin at index `0`.

---

## 2. Display array elements

Display every element on one line:

```bash
echo "${items[@]}"
```

Display one element per line:

```bash
printf '%s\n' "${items[@]}"
```

Display one particular element:

```bash
echo "${items[2]}"
```

Output:

```text
mango
```

Display the number of elements:

```bash
echo "${#items[@]}"
```

Output:

```text
5
```

---

## 3. Array-slicing syntax

```bash
"${array_name[@]:offset:length}"
```

| Part | Meaning |
|---|---|
| `array_name` | Name of the array |
| `[@]` | Expand all selected elements separately |
| `offset` | Index where the slice starts |
| `length` | Number of elements to select |

Example:

```bash
items=(apple banana mango orange grapes)
printf '%s\n' "${items[@]:1:3}"
```

Output:

```text
banana
mango
orange
```

The slice starts at index `1` and selects `3` elements.

---

## 4. First array-slicing script

### Script name: `array_slice_demo.sh`

Create the script:

```bash
vim array_slice_demo.sh
```

Add:

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

selected_items=( "${items[@]:1:3}" )

echo "Original array:"
printf '%s\n' "${items[@]}"

echo
echo "Selected elements:"
printf '%s\n' "${selected_items[@]}"
```

Run it:

```bash
bash array_slice_demo.sh
```

Output:

```text
Original array:
apple
banana
mango
orange
grapes

Selected elements:
banana
mango
orange
```

---

## 5. Common slicing operations

Assume this array:

```bash
items=(apple banana mango orange grapes)
```

### Select the first two elements

```bash
printf '%s\n' "${items[@]:0:2}"
```

Output:

```text
apple
banana
```

### Select three elements starting at index 2

```bash
printf '%s\n' "${items[@]:2:3}"
```

Output:

```text
mango
orange
grapes
```

### Select from index 2 to the end

If the length is omitted, Bash selects every remaining element:

```bash
printf '%s\n' "${items[@]:2}"
```

Output:

```text
mango
orange
grapes
```

### Select the last two elements

```bash
printf '%s\n' "${items[@]: -2}"
```

Output:

```text
orange
grapes
```

There must be a space before a negative offset:

```bash
"${items[@]: -2}"
```

Without the space, `:-` can be interpreted as the parameter-expansion default-value operator.

---

## 6. Keep only the first two elements

To permanently shorten the current array, assign the slice back to the same array:

```bash
items=( "${items[@]:0:2}" )
```

### Script name: `keep_first_two.sh`

Create the script:

```bash
vim keep_first_two.sh
```

Add:

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

echo "Before: ${items[*]}"

items=( "${items[@]:0:2}" )

echo "After:  ${items[*]}"
```

Run it:

```bash
bash keep_first_two.sh
```

Output:

```text
Before: apple banana mango orange grapes
After:  apple banana
```

This changes only the array in memory. It does not delete files from the filesystem.

---

## 7. Keep the first `N` elements

Use a variable as the slice length:

### Script name: `keep_first_n.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)
keep=3

items=( "${items[@]:0:keep}" )

printf '%s\n' "${items[@]}"
```

Output:

```text
apple
banana
mango
```

The `offset` and `length` fields are arithmetic expressions, so Bash can use the integer variable `keep` there.

---

## 8. Remove the first `N` elements

Start the new slice at index `N` and omit the length:

```bash
items=( "${items[@]:2}" )
```

### Script name: `remove_first_two.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

items=( "${items[@]:2}" )

printf '%s\n' "${items[@]}"
```

Output:

```text
mango
orange
grapes
```

---

## 9. Keep the last `N` elements

Use a negative offset:

```bash
items=( "${items[@]: -2}" )
```

### Script name: `keep_last_two.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

items=( "${items[@]: -2}" )

printf '%s\n' "${items[@]}"
```

Output:

```text
orange
grapes
```

---

## 10. Remove the last `N` elements

Calculate how many elements should remain:

### Script name: `remove_last_two.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)
remove=2
keep=$(( ${#items[@]} - remove ))

if (( keep < 0 )); then
    keep=0
fi

items=( "${items[@]:0:keep}" )

printf '%s\n' "${items[@]}"
```

Output:

```text
apple
banana
mango
```

Explanation:

```bash
${#items[@]}
```

returns the number of elements. If there are five elements and two must be removed:

```text
keep = 5 - 2 = 3
```

The guard prevents a negative slice length when `remove` is larger than the array.

---

## 11. Remove one element by position

To remove an element while keeping the order compact, combine the part before it with the part after it.

### Script name: `remove_array_element.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)
remove_index=2

items=(
    "${items[@]:0:remove_index}"
    "${items[@]:remove_index+1}"
)

printf '%s\n' "${items[@]}"
```

Output:

```text
apple
banana
orange
grapes
```

The value `mango`, originally at index `2`, is removed.

---

## 12. Replace part of an array

Combine slices with replacement values.

### Script name: `replace_array_slice.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

items=(
    "${items[@]:0:1}"
    peach
    pear
    "${items[@]:3}"
)

printf '%s\n' "${items[@]}"
```

Output:

```text
apple
peach
pear
orange
grapes
```

The elements at indexes `1` and `2` are replaced by `peach` and `pear`.

---

## 13. Preserve elements containing spaces

Always quote array expansions.

### Script name: `slice_values_with_spaces.sh`

```bash
#!/bin/bash

courses=(
    "Linux Administration"
    "Bash Scripting"
    "Amazon Web Services"
    "Container Fundamentals"
)

selected=( "${courses[@]:1:2}" )

printf '<%s>\n' "${selected[@]}"
```

Output:

```text
<Bash Scripting>
<Amazon Web Services>
```

Incorrect:

```bash
selected=( ${courses[@]:1:2} )
```

The unquoted expansion can split one array element into multiple words.

Correct:

```bash
selected=( "${courses[@]:1:2}" )
```

---

## 14. Difference between `[@]` and `[*]`

Inside double quotes:

```bash
"${items[@]}"
```

expands each element as a separate argument.

```bash
"${items[*]}"
```

joins all elements into one string using the first character of `IFS`, normally a space.

For slicing and copying arrays, prefer:

```bash
new_array=( "${items[@]:1:3}" )
```

For a simple one-line display, this is convenient:

```bash
echo "${items[*]}"
```

---

## 15. Slice command-line arguments

Positional parameters can also be sliced:

```bash
"${@:offset:length}"
```

For positional parameters, offset `1` refers to `$1`. The script name remains `$0`.

### Script name: `argument_slice_demo.sh`

```bash
#!/bin/bash

selected_arguments=( "${@:2:3}" )

printf '%s\n' "${selected_arguments[@]}"
```

Run:

```bash
bash argument_slice_demo.sh apple banana mango orange grapes
```

Output:

```text
banana
mango
orange
```

---

## 16. Validate a requested slice

The user can provide the starting index and number of elements.

### Script name: `dynamic_array_slice.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes watermelon)

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <start-index> <length>" >&2
    exit 1
fi

start=$1
length=$2

if [[ ! $start =~ ^[0-9]+$ || ! $length =~ ^[0-9]+$ ]]; then
    echo "Error: start index and length must be non-negative integers." >&2
    exit 1
fi

if (( start >= ${#items[@]} )); then
    echo "Error: start index is outside the array." >&2
    exit 1
fi

selected=( "${items[@]:start:length}" )

printf '%s\n' "${selected[@]}"
```

Run:

```bash
bash dynamic_array_slice.sh 2 3
```

Output:

```text
mango
orange
grapes
```

---

## 17. Slice files collected with a glob

### Script name: `first_three_text_files.sh`

```bash
#!/bin/bash

shopt -s nullglob

files=( ./*.txt )

if (( ${#files[@]} == 0 )); then
    echo "No .txt files found." >&2
    exit 1
fi

first_three=( "${files[@]:0:3}" )

printf '%s\n' "${first_three[@]}"
```

`nullglob` makes an unmatched pattern expand to nothing instead of leaving the literal text `./*.txt` in the array.

This script only lists filenames. It does not modify or delete them.

---

## 18. Indexed arrays versus associative arrays

Slicing is designed for indexed arrays:

```bash
items=(apple banana mango)
```

Associative arrays use named keys:

```bash
declare -A user=(
    [name]="Khalid"
    [role]="Linux Administrator"
)
```

Associative arrays do not provide a dependable positional order for meaningful slicing. Access their values by key instead:

```bash
echo "${user[name]}"
```

---

## 19. Important behavior and edge cases

### Length larger than the remaining array

Bash returns only the elements that exist:

```bash
items=(a b c)
printf '%s\n' "${items[@]:1:20}"
```

Output:

```text
b
c
```

### Offset outside the array

The expansion produces no elements:

```bash
printf '%s\n' "${items[@]:20:2}"
```

### Zero length

This selects no elements:

```bash
slice=( "${items[@]:1:0}" )
```

### Empty array

Slicing an empty array produces an empty result:

```bash
items=()
slice=( "${items[@]:0:2}" )
```

---

## 20. Sparse-array caution

Bash arrays can contain missing indexes:

```bash
items=()
items[0]=apple
items[3]=orange
items[7]=grapes
```

Display the stored indexes:

```bash
printf '%s\n' "${!items[@]}"
```

Output:

```text
0
3
7
```

Array slicing walks through the existing expanded elements; it should not be treated as a reliable way to preserve sparse numeric indexes. Reassigning a slice creates a compact array beginning at index `0`.

---

## 21. Common mistakes

### Mistake 1: Forgetting that indexes begin at zero

```bash
items=(apple banana mango)
echo "${items[0]}"
```

The first element is at index `0`, not index `1`.

### Mistake 2: Confusing offset with length

```bash
"${items[@]:2:3}"
```

This means “start at index `2` and select `3` elements.” It does not mean “select through index `3`.”

### Mistake 3: Forgetting quotes

Incorrect:

```bash
slice=( ${items[@]:1:2} )
```

Correct:

```bash
slice=( "${items[@]:1:2}" )
```

### Mistake 4: Forgetting the space before a negative offset

Correct:

```bash
"${items[@]: -2}"
```

### Mistake 5: Expecting a slice to modify the original array

This only prints a slice:

```bash
printf '%s\n' "${items[@]:0:2}"
```

This modifies the array:

```bash
items=( "${items[@]:0:2}" )
```

### Mistake 6: Thinking array removal deletes files

Changing this array:

```bash
files=( "${files[@]:0:2}" )
```

changes only the Bash variable. It does not remove any filesystem objects.

---

# Practice problems

Try each problem before reading its solution.

## Problem 1: Print the first three colors

Given:

```bash
colors=(red blue green yellow purple)
```

Print only `red`, `blue`, and `green`.

### Solution — script name: `problem01_first_three.sh`

```bash
#!/bin/bash

colors=(red blue green yellow purple)

printf '%s\n' "${colors[@]:0:3}"
```

---

## Problem 2: Print from the third element to the end

Given:

```bash
servers=(web01 web02 db01 db02 cache01)
```

Print `db01`, `db02`, and `cache01`.

### Solution — script name: `problem02_third_to_end.sh`

```bash
#!/bin/bash

servers=(web01 web02 db01 db02 cache01)

printf '%s\n' "${servers[@]:2}"
```

---

## Problem 3: Keep only the first two users

Given:

```bash
users=(ali sara khalid ibrahim maryam)
```

Modify the original array so it contains only `ali` and `sara`.

### Solution — script name: `problem03_keep_first_two.sh`

```bash
#!/bin/bash

users=(ali sara khalid ibrahim maryam)

users=( "${users[@]:0:2}" )

printf '%s\n' "${users[@]}"
```

---

## Problem 4: Remove the first two ports

Given:

```bash
ports=(22 80 443 3306 5432)
```

Keep only `443`, `3306`, and `5432`.

### Solution — script name: `problem04_remove_first_two.sh`

```bash
#!/bin/bash

ports=(22 80 443 3306 5432)

ports=( "${ports[@]:2}" )

printf '%s\n' "${ports[@]}"
```

---

## Problem 5: Keep the last three log names

Given:

```bash
logs=(app1.log app2.log app3.log app4.log app5.log)
```

Keep only the last three elements.

### Solution — script name: `problem05_keep_last_three.sh`

```bash
#!/bin/bash

logs=(app1.log app2.log app3.log app4.log app5.log)

logs=( "${logs[@]: -3}" )

printf '%s\n' "${logs[@]}"
```

---

## Problem 6: Save the middle three elements

Given:

```bash
numbers=(10 20 30 40 50 60 70)
```

Create a new array containing `30`, `40`, and `50`. Do not modify the original array.

### Solution — script name: `problem06_middle_three.sh`

```bash
#!/bin/bash

numbers=(10 20 30 40 50 60 70)

middle=( "${numbers[@]:2:3}" )

echo "Original: ${numbers[*]}"
echo "Middle:   ${middle[*]}"
```

---

## Problem 7: Remove the last element

Given:

```bash
packages=(bash git curl wget vim)
```

Modify the array so `vim` is removed.

### Solution — script name: `problem07_remove_last.sh`

```bash
#!/bin/bash

packages=(bash git curl wget vim)
keep=$(( ${#packages[@]} - 1 ))

packages=( "${packages[@]:0:keep}" )

printf '%s\n' "${packages[@]}"
```

---

## Problem 8: Keep a user-selected number of elements

The first argument should specify how many elements to keep from this array:

```bash
days=(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
```

### Solution — script name: `problem08_keep_requested_count.sh`

```bash
#!/bin/bash

days=(Monday Tuesday Wednesday Thursday Friday Saturday Sunday)

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <number-to-keep>" >&2
    exit 1
fi

keep=$1

if [[ ! $keep =~ ^[0-9]+$ ]]; then
    echo "Error: provide a non-negative integer." >&2
    exit 1
fi

days=( "${days[@]:0:keep}" )

printf '%s\n' "${days[@]}"
```

Example:

```bash
bash problem08_keep_requested_count.sh 4
```

---

## Problem 9: Display three arguments starting from `$2`

Pass five fruits to the script and display the second, third, and fourth arguments.

### Solution — script name: `problem09_argument_slice.sh`

```bash
#!/bin/bash

if (( $# < 4 )); then
    echo "Usage: $0 <value1> <value2> <value3> <value4> [more...]" >&2
    exit 1
fi

printf '%s\n' "${@:2:3}"
```

Run:

```bash
bash problem09_argument_slice.sh apple banana mango orange grapes
```

---

## Problem 10: Select filenames containing spaces safely

Given an array containing filenames with spaces, select the second and third filenames without splitting them.

### Solution — script name: `problem10_filenames_with_spaces.sh`

```bash
#!/bin/bash

files=(
    "January Report.txt"
    "February Report.txt"
    "March Report.txt"
    "April Report.txt"
)

selected=( "${files[@]:1:2}" )

printf '<%s>\n' "${selected[@]}"
```

---

## Problem 11: Remove an element at a supplied index

Accept an index as `$1` and remove the element at that index.

### Solution — script name: `problem11_remove_by_index.sh`

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

if [[ $# -ne 1 || ! $1 =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 <non-negative-index>" >&2
    exit 1
fi

remove_index=$1

if (( remove_index >= ${#items[@]} )); then
    echo "Error: index is outside the array." >&2
    exit 1
fi

items=(
    "${items[@]:0:remove_index}"
    "${items[@]:remove_index+1}"
)

printf '%s\n' "${items[@]}"
```

---

## Problem 12: Divide an array into two parts

Given:

```bash
hosts=(host01 host02 host03 host04 host05 host06)
```

Store the first three hosts in `group_a` and the remaining hosts in `group_b`.

### Solution — script name: `problem12_split_array.sh`

```bash
#!/bin/bash

hosts=(host01 host02 host03 host04 host05 host06)

group_a=( "${hosts[@]:0:3}" )
group_b=( "${hosts[@]:3}" )

echo "Group A: ${group_a[*]}"
echo "Group B: ${group_b[*]}"
```

---

## Problem 13: Process the first three `.txt` files

Collect `.txt` filenames from the current directory and display only the first three.

### Solution — script name: `problem13_first_three_files.sh`

```bash
#!/bin/bash

shopt -s nullglob
files=( ./*.txt )

if (( ${#files[@]} == 0 )); then
    echo "No .txt files found." >&2
    exit 1
fi

selected=( "${files[@]:0:3}" )

printf '%s\n' "${selected[@]}"
```

---

## Problem 14: Replace the middle two services

Given:

```bash
services=(ssh nginx apache mysql docker)
```

Replace `nginx` and `apache` with `httpd` and `haproxy`.

### Solution — script name: `problem14_replace_middle.sh`

```bash
#!/bin/bash

services=(ssh nginx apache mysql docker)

services=(
    "${services[@]:0:1}"
    httpd
    haproxy
    "${services[@]:3}"
)

printf '%s\n' "${services[@]}"
```

---

## Problem 15: Create a reusable first-`N` function

Write a function that receives a number followed by array values and prints the first requested number of values.

### Solution — script name: `problem15_first_n_function.sh`

```bash
#!/bin/bash

print_first_n() {
    local count=$1
    shift

    local values=( "$@" )

    printf '%s\n' "${values[@]:0:count}"
}

print_first_n 3 apple banana mango orange grapes
```

Output:

```text
apple
banana
mango
```

---

## 22. Challenge problems without solutions

1. Create an array of ten numbers and print elements at indexes `3` through `6`.
2. Keep only the last four elements of a seven-element array.
3. Remove the first three elements and save the result in a new array without changing the original.
4. Accept `start` and `length` from command-line arguments and validate both values.
5. Split an array into two halves. Consider what should happen when the array contains an odd number of elements.
6. Remove the element at index `0` using slicing.
7. Remove the final element without hard-coding the array length.
8. Create an array from all `.sh` files and display only the newest five after sorting the filenames.
9. Select three filenames that contain spaces and prove that each remains one array element.
10. Write a script that keeps the first `N` values when `N` is smaller than the array length and keeps the whole array when `N` is larger.

---

## 23. Quick-reference table

Assume:

```bash
items=(a b c d e)
```

| Goal | Command | Result |
|---|---|---|
| First two | `"${items[@]:0:2}"` | `a b` |
| From index 2 to end | `"${items[@]:2}"` | `c d e` |
| Three from index 1 | `"${items[@]:1:3}"` | `b c d` |
| Last two | `"${items[@]: -2}"` | `d e` |
| Keep first two | `items=( "${items[@]:0:2}" )` | array becomes `a b` |
| Remove first two | `items=( "${items[@]:2}" )` | array becomes `c d e` |
| Copy a slice | `copy=( "${items[@]:1:2}" )` | `copy` becomes `b c` |
| Element count | `${#items[@]}` | `5` |
| Stored indexes | `${!items[@]}` | `0 1 2 3 4` |

---

## 24. Final best practices

- Use indexed arrays when positional order matters.
- Remember that indexed arrays normally start at index `0`.
- Quote array expansions: `"${array[@]}"`.
- Use `[@]` when copying or slicing arrays.
- Include a space before a negative offset: `${array[@]: -2}`.
- Reassign a slice to modify the original array.
- Validate user-provided offsets and lengths.
- Use `shopt -s nullglob` when building arrays from filename globs.
- Remember that modifying an array never deletes the referenced files.
- Use `printf '%s\n'` when you want one element per line.

## Summary

Bash array slicing uses:

```bash
"${array[@]:offset:length}"
```

The offset tells Bash where to begin, and the length tells it how many elements to return. A slice only produces selected values; it changes the original array only when you assign the result back to that array.
