# Bash Array Slicing — Mukammal Study Notes aur Practice Problems (Roman Urdu)

## Learning objectives

In notes ko complete karne ke baad aap:

- Bash indexed array create aur display kar sakein ge;
- array indexes ko samajh sakein ge;
- slicing se array ka selected hissa nikal sakein ge;
- shuru ya aakhir ke elements keep/remove kar sakein ge;
- slice ko nayi array mein save kar sakein ge;
- command-line arguments ko slice kar sakein ge;
- spaces wali values ko safely handle kar sakein ge;
- common array-slicing mistakes se bach sakein ge;
- practical array problems solve kar sakein ge.

---

## 1. Bash array kya hoti hai?

Bash array aik variable hoti hai jo multiple values ko aik saath store kar sakti hai.

```bash
items=(apple banana mango orange grapes)
```

Array ka naam `items` hai aur is mein paanch elements hain.

| Index | Element |
|---:|---|
| `0` | `apple` |
| `1` | `banana` |
| `2` | `mango` |
| `3` | `orange` |
| `4` | `grapes` |

Bash indexed array aam tor par index `0` se shuru hoti hai.

---

## 2. Array elements display karna

Tamam elements aik row mein:

```bash
echo "${items[@]}"
```

Har element alag line par:

```bash
printf '%s\n' "${items[@]}"
```

Koi aik particular element:

```bash
echo "${items[2]}"
```

Output:

```text
mango
```

Elements ki total tadaad:

```bash
echo "${#items[@]}"
```

Output:

```text
5
```

---

## 3. Array slicing kya hai?

Array slicing ka matlab poori array mein se selected elements ka aik hissa nikalna hai.

General syntax:

```bash
"${array_name[@]:offset:length}"
```

| Hissa | Matlab |
|---|---|
| `array_name` | Array ka naam |
| `[@]` | Selected elements ko alag-alag values ke taur par expand karta hai |
| `offset` | Slice kis index se shuru hogi |
| `length` | Kitne elements select karne hain |

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

Yeh slice index `1` se shuru hui aur `3` elements select kiye.

---

## 4. Pehla array-slicing script

### Script name: `array_slice_demo.sh`

Script create karein:

```bash
vim array_slice_demo.sh
```

Code:

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

Run karein:

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

Yeh array assume karein:

```bash
items=(apple banana mango orange grapes)
```

### Pehle do elements select karna

```bash
printf '%s\n' "${items[@]:0:2}"
```

Output:

```text
apple
banana
```

### Index 2 se teen elements select karna

```bash
printf '%s\n' "${items[@]:2:3}"
```

Output:

```text
mango
orange
grapes
```

### Index 2 se aakhir tak select karna

Length na dein to Bash baqi tamam elements select karta hai:

```bash
printf '%s\n' "${items[@]:2}"
```

Output:

```text
mango
orange
grapes
```

### Aakhri do elements select karna

```bash
printf '%s\n' "${items[@]: -2}"
```

Output:

```text
orange
grapes
```

Negative offset se pehle space zaroor rakhein:

```bash
"${items[@]: -2}"
```

Agar space na ho to Bash `:-` ko default-value parameter expansion samajh sakta hai.

---

## 6. Sirf pehle do elements keep karna

Slice ko wapas isi array mein assign karein:

```bash
items=( "${items[@]:0:2}" )
```

### Script name: `keep_first_two.sh`

Script create karein:

```bash
vim keep_first_two.sh
```

Code:

```bash
#!/bin/bash

items=(apple banana mango orange grapes)

echo "Before: ${items[*]}"

items=( "${items[@]:0:2}" )

echo "After:  ${items[*]}"
```

Run karein:

```bash
bash keep_first_two.sh
```

Output:

```text
Before: apple banana mango orange grapes
After:  apple banana
```

Yeh sirf memory mein mojood Bash array ko change karta hai. Is se filesystem ki files delete nahi hotin.

---

## 7. Pehle `N` elements keep karna

Slice length mein variable use kiya ja sakta hai.

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

`offset` aur `length` arithmetic expressions hoti hain, is liye Bash `keep` jaisa integer variable yahan use kar sakta hai.

---

## 8. Pehle `N` elements remove karna

Naye slice ko index `N` se shuru karein aur length na dein:

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

## 9. Aakhri `N` elements keep karna

Negative offset use karein:

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

## 10. Aakhri `N` elements remove karna

Pehle calculate karein ke kitne elements keep karne hain.

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

` ${#items[@]} ` array ke elements ki total tadaad deta hai. Agar paanch elements mein se do remove karne hon:

```text
keep = 5 - 2 = 3
```

Guard condition negative slice length se bachati hai jab `remove` array ke size se bara ho.

---

## 11. Kisi particular index ka element remove karna

Element se pehle wali slice aur us ke baad wali slice ko mila dein.

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

Index `2` par mojood `mango` remove ho gaya.

---

## 12. Array ke aik hisse ko replace karna

Old slices ke darmiyan replacement values add karein.

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

Indexes `1` aur `2` ke elements ko `peach` aur `pear` se replace kiya gaya.

---

## 13. Spaces wali values ko preserve karna

Array expansion ko hamesha double quotes mein rakhein.

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

Ghalat:

```bash
selected=( ${courses[@]:1:2} )
```

Unquoted expansion aik element ko multiple words mein split kar sakti hai.

Sahi:

```bash
selected=( "${courses[@]:1:2}" )
```

---

## 14. `[@]` aur `[*]` mein farq

Double quotes ke andar:

```bash
"${items[@]}"
```

har element ko alag argument ke taur par expand karta hai.

```bash
"${items[*]}"
```

tamam elements ko aik string mein join karta hai. Separator aam tor par space hota hai.

Array copy ya slice karne ke liye yeh prefer karein:

```bash
new_array=( "${items[@]:1:3}" )
```

Aik row mein simple display ke liye:

```bash
echo "${items[*]}"
```

---

## 15. Command-line arguments ko slice karna

Positional parameters bhi slice kiye ja sakte hain:

```bash
"${@:offset:length}"
```

Positional parameters mein offset `1`, `$1` ko refer karta hai. Script ka naam `$0` mein rehta hai.

### Script name: `argument_slice_demo.sh`

```bash
#!/bin/bash

selected_arguments=( "${@:2:3}" )

printf '%s\n' "${selected_arguments[@]}"
```

Run karein:

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

## 16. User se start aur length lena

User start index aur elements ki tadaad command-line arguments ke zariye de sakta hai.

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

Run karein:

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

## 17. Glob se collect ki gayi files ko slice karna

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

`nullglob` unmatched pattern ko empty result banata hai. Is ke baghair literal text `./*.txt` array mein aa sakta hai.

Yeh script sirf filenames list karti hai; files ko modify ya delete nahi karti.

---

## 18. Indexed aur associative arrays

Slicing indexed arrays ke liye hoti hai:

```bash
items=(apple banana mango)
```

Associative arrays named keys use karti hain:

```bash
declare -A user=(
    [name]="Khalid"
    [role]="Linux Administrator"
)
```

Associative array ki dependable positional order nahi hoti, is liye meaningful slicing ke bajaye key se value access karein:

```bash
echo "${user[name]}"
```

---

## 19. Important behavior aur edge cases

### Length remaining elements se bari ho

Bash sirf available elements return karega:

```bash
items=(a b c)
printf '%s\n' "${items[@]:1:20}"
```

Output:

```text
b
c
```

### Offset array se bahar ho

Expansion koi element return nahi karegi:

```bash
slice=( "${items[@]:20:2}" )
```

### Length zero ho

Koi element select nahi hoga:

```bash
slice=( "${items[@]:1:0}" )
```

### Array empty ho

Result bhi empty array hoga:

```bash
items=()
slice=( "${items[@]:0:2}" )
```

---

## 20. Sparse array caution

Bash array mein indexes missing ho sakte hain:

```bash
items=()
items[0]=apple
items[3]=orange
items[7]=grapes
```

Stored indexes display karein:

```bash
printf '%s\n' "${!items[@]}"
```

Output:

```text
0
3
7
```

Slicing existing expanded elements par chalti hai. Slice ko reassign karne par aam tor par compact array banti hai jo index `0` se shuru hoti hai. Sparse numeric indexes preserve karne ke liye slicing par depend na karein.

---

## 21. Common mistakes

### Mistake 1: Index zero ko bhool jana

```bash
items=(apple banana mango)
echo "${items[0]}"
```

Pehla element index `0` par hota hai, index `1` par nahi.

### Mistake 2: Offset aur length ko confuse karna

```bash
"${items[@]:2:3}"
```

Is ka matlab hai: index `2` se shuru karein aur `3` elements select karein. Is ka matlab index `3` tak select karna nahi.

### Mistake 3: Double quotes bhool jana

Ghalat:

```bash
slice=( ${items[@]:1:2} )
```

Sahi:

```bash
slice=( "${items[@]:1:2}" )
```

### Mistake 4: Negative offset se pehle space na dena

Sahi:

```bash
"${items[@]: -2}"
```

### Mistake 5: Yeh samajhna ke slice original array ko khud change karegi

Yeh sirf slice print karta hai:

```bash
printf '%s\n' "${items[@]:0:2}"
```

Yeh original array modify karta hai:

```bash
items=( "${items[@]:0:2}" )
```

### Mistake 6: Array se value hatane ko file deletion samajhna

```bash
files=( "${files[@]:0:2}" )
```

Yeh sirf Bash variable change karta hai. Filesystem ki koi file delete nahi hoti.

---

# Practice problems with solutions

Har problem ko solution dekhne se pehle khud solve karne ki koshish karein.

## Problem 1: Pehle teen colors print karein

Given array:

```bash
colors=(red blue green yellow purple)
```

Sirf `red`, `blue`, aur `green` print karein.

### Solution — script name: `problem01_first_three.sh`

```bash
#!/bin/bash

colors=(red blue green yellow purple)

printf '%s\n' "${colors[@]:0:3}"
```

---

## Problem 2: Teesray element se aakhir tak print karein

Given:

```bash
servers=(web01 web02 db01 db02 cache01)
```

`db01`, `db02`, aur `cache01` print karein.

### Solution — script name: `problem02_third_to_end.sh`

```bash
#!/bin/bash

servers=(web01 web02 db01 db02 cache01)

printf '%s\n' "${servers[@]:2}"
```

---

## Problem 3: Sirf pehle do users keep karein

Given:

```bash
users=(ali sara khalid ibrahim maryam)
```

Original array ko modify karke sirf `ali` aur `sara` rakhein.

### Solution — script name: `problem03_keep_first_two.sh`

```bash
#!/bin/bash

users=(ali sara khalid ibrahim maryam)

users=( "${users[@]:0:2}" )

printf '%s\n' "${users[@]}"
```

---

## Problem 4: Pehle do ports remove karein

Given:

```bash
ports=(22 80 443 3306 5432)
```

Sirf `443`, `3306`, aur `5432` keep karein.

### Solution — script name: `problem04_remove_first_two.sh`

```bash
#!/bin/bash

ports=(22 80 443 3306 5432)

ports=( "${ports[@]:2}" )

printf '%s\n' "${ports[@]}"
```

---

## Problem 5: Aakhri teen log names keep karein

Given:

```bash
logs=(app1.log app2.log app3.log app4.log app5.log)
```

Sirf aakhri teen elements keep karein.

### Solution — script name: `problem05_keep_last_three.sh`

```bash
#!/bin/bash

logs=(app1.log app2.log app3.log app4.log app5.log)

logs=( "${logs[@]: -3}" )

printf '%s\n' "${logs[@]}"
```

---

## Problem 6: Darmiyan ke teen elements save karein

Given:

```bash
numbers=(10 20 30 40 50 60 70)
```

`30`, `40`, aur `50` ko nayi array mein save karein. Original array change na karein.

### Solution — script name: `problem06_middle_three.sh`

```bash
#!/bin/bash

numbers=(10 20 30 40 50 60 70)

middle=( "${numbers[@]:2:3}" )

echo "Original: ${numbers[*]}"
echo "Middle:   ${middle[*]}"
```

---

## Problem 7: Aakhri element remove karein

Given:

```bash
packages=(bash git curl wget vim)
```

Array ko modify karein taa-ke `vim` remove ho jaye.

### Solution — script name: `problem07_remove_last.sh`

```bash
#!/bin/bash

packages=(bash git curl wget vim)
keep=$(( ${#packages[@]} - 1 ))

packages=( "${packages[@]:0:keep}" )

printf '%s\n' "${packages[@]}"
```

---

## Problem 8: User ke diye hue number ke mutabiq elements keep karein

Pehla argument bataye ke is array mein se kitne elements keep karne hain:

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

## Problem 9: `$2` se shuru hone wale teen arguments display karein

Script ko paanch fruits dein aur second, third, aur fourth arguments display karein.

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

## Problem 10: Spaces wale filenames safely select karein

Spaces wale filenames ki array mein se second aur third filenames select karein aur unhein split na hone dein.

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

## Problem 11: User ke diye hue index ka element remove karein

`$1` mein index accept karein aur us index ka element remove karein.

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

## Problem 12: Array ko do groups mein divide karein

Given:

```bash
hosts=(host01 host02 host03 host04 host05 host06)
```

Pehle teen hosts `group_a` aur baqi hosts `group_b` mein save karein.

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

## Problem 13: Pehli teen `.txt` files process karein

Current directory ki `.txt` filenames collect karein aur sirf pehli teen display karein.

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

## Problem 14: Darmiyan ki do services replace karein

Given:

```bash
services=(ssh nginx apache mysql docker)
```

`nginx` aur `apache` ko `httpd` aur `haproxy` se replace karein.

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

## Problem 15: Reusable first-`N` function banayein

Aisi function likhein jo pehle number aur phir array values le aur requested number ke mutabiq pehli values print kare.

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

## 22. Challenge problems — solutions ke baghair

1. Das numbers ki array banayein aur indexes `3` se `6` tak ke elements print karein.
2. Saat-element array mein se sirf aakhri chaar elements keep karein.
3. Pehle teen elements remove karke result nayi array mein save karein; original array change na karein.
4. Command-line se `start` aur `length` accept karein aur dono values validate karein.
5. Array ko do halves mein divide karein. Agar elements odd hon to decide karein extra element kis group mein jayega.
6. Slicing use karke index `0` ka element remove karein.
7. Array length hard-code kiye baghair aakhri element remove karein.
8. Tamam `.sh` files ki array banayein, filenames sort karein aur sirf aakhri paanch select karein.
9. Spaces wale teen filenames select karein aur prove karein ke har filename aik hi array element raha.
10. Aisi script banayein jo pehle `N` values keep kare. Agar `N` array length se bara ho to poori array keep rahe.

---

## 23. Quick-reference table

Assume karein:

```bash
items=(a b c d e)
```

| Goal | Command | Result |
|---|---|---|
| Pehle do | `"${items[@]:0:2}"` | `a b` |
| Index 2 se aakhir tak | `"${items[@]:2}"` | `c d e` |
| Index 1 se teen | `"${items[@]:1:3}"` | `b c d` |
| Aakhri do | `"${items[@]: -2}"` | `d e` |
| Pehle do keep | `items=( "${items[@]:0:2}" )` | array `a b` ban jayegi |
| Pehle do remove | `items=( "${items[@]:2}" )` | array `c d e` ban jayegi |
| Slice copy | `copy=( "${items[@]:1:2}" )` | `copy` mein `b c` |
| Elements count | `${#items[@]}` | `5` |
| Stored indexes | `${!items[@]}` | `0 1 2 3 4` |

---

## 24. Final best practices

- Jab positional order important ho to indexed array use karein.
- Yaad rakhein ke indexed array aam tor par index `0` se shuru hoti hai.
- Array expansion ko quote karein: `"${array[@]}"`.
- Array copy aur slicing ke liye `[@]` use karein.
- Negative offset se pehle space dein: `${array[@]: -2}`.
- Original array modify karne ke liye slice ko wapas assign karein.
- User-provided offset aur length validate karein.
- Filename globs se array banate waqt `shopt -s nullglob` use karein.
- Array modify karna referenced files ko delete nahi karta.
- Har element alag line par dikhane ke liye `printf '%s\n'` use karein.

## Summary

Bash array slicing ka basic syntax hai:

```bash
"${array[@]:offset:length}"
```

`offset` batata hai slicing kahan se shuru hogi aur `length` batata hai kitne elements return honge. Slice sirf selected values nikalti hai. Original array tab change hoti hai jab slice ko wapas usi array mein assign kiya jaye.
