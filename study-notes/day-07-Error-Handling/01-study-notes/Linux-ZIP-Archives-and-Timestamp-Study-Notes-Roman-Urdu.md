# Linux Archive aur Compression — `zip`, `tar`, `gzip`, `bzip2` aur `xz` Study Notes (Roman Urdu)

## 1. `zip` kya hai?

`zip` Linux command files aur directories ko aik `.zip` archive mein jama aur compress karta hai.

```text
file1.txt + file2.txt + documents/  →  backup.zip
```

- **Archive:** multiple files aur directories ko aik package mein jama karna.
- **Compression:** data ka size kam karna.
- **Extraction:** archive ke andar ki files ko wapas bahar nikalna.

ZIP format aam tor par archiving aur compression dono karta hai.

---

## 2. Installation

Ubuntu, Debian aur WSL Ubuntu par:

```bash
sudo apt update
sudo apt install zip unzip -y
```

RHEL, Rocky Linux, AlmaLinux aur Fedora par:

```bash
sudo dnf install zip unzip -y
```

Installation verify karein:

```bash
zip --version
unzip -v
```

---

## 3. `man zip` ka error

Agar command chalane par yeh message aaye:

```text
No manual entry for zip
```

to pehle check karein ke `zip` installed hai:

```bash
command -v zip
zip --version
```

Ubuntu/WSL mein package aur manual database reinstall/update karein:

```bash
sudo apt install --reinstall zip man-db -y
sudo mandb
man zip
```

Quick help ke liye:

```bash
zip --help
```

---

## 4. General syntax

```bash
zip [options] archive-name.zip source...
```

Example:

```bash
zip backup.zip file1.txt file2.txt
```

| Hissa | Matlab |
|---|---|
| `zip` | Command |
| `backup.zip` | Ban-ne wali archive ka naam |
| `file1.txt file2.txt` | Source files |

> Archive ka naam source files se pehle diya jata hai.

---

## 5. Basic examples

### Aik file archive karna

```bash
zip backup.zip file1.txt
```

### Multiple files archive karna

```bash
zip backup.zip file1.txt file2.txt file3.txt
```

### Directory archive karna

Directory ke tamam contents include karne ke liye `-r` zaroori hai:

```bash
zip -r project.zip project/
```

### Files aur directory aik saath archive karna

```bash
zip -r backup.zip file1.txt file2.txt documents/
```

---

## 6. Archive ke naam par timestamp

### Question

**How can I add a date and time (timestamp) to the filename of a ZIP archive in Linux?**

**Roman Urdu:** Linux mein ZIP archive ke filename ke saath date aur time ka timestamp kaise add kar sakte hain?

### Answer

Current date aur time archive ke filename mein add karne ke liye command substitution use karein:

```bash
zip -r "backup_$(date +%Y-%m-%d_%H-%M-%S).zip" documents/
```

Possible output filename:

```text
backup_2026-08-16_23-45-30.zip
```

### Date format table

| Format | Matlab | Example |
|---|---|---|
| `%Y` | 4-digit year | `2026` |
| `%m` | Month | `08` |
| `%d` | Day | `16` |
| `%H` | Hour, 24-hour format | `23` |
| `%M` | Minute | `45` |
| `%S` | Second | `30` |

> Filename mein `:` ke bajaye `-` use karna behtar hai, khas tor par jab archive Windows ke saath share karni ho.

### Sirf date lagana

```bash
zip -r "backup_$(date +%Y-%m-%d).zip" documents/
```

Output:

```text
backup_2026-08-16.zip
```

### Variables ke saath readable version

```bash
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
archive="backup_${timestamp}.zip"

zip -r "$archive" documents/

echo "Archive created: $archive"
```

Double quotes filename ko spaces aur special-character problems se protect karti hain.

---

## 7. Common `zip` options

| Option | Kaam | Example |
|---|---|---|
| `-r` | Directory ko recursively include kare | `zip -r project.zip project/` |
| `-q` | Quiet mode; normal output hide kare | `zip -q backup.zip file.txt` |
| `-u` | Sirf new ya updated files add kare | `zip -u backup.zip file.txt` |
| `-d` | Archive se matching file delete kare | `zip -d backup.zip file.txt` |
| `-e` | Password prompt ke saath encrypt kare | `zip -e private.zip file.txt` |
| `-x` | Matching files exclude kare | `zip -r project.zip project/ -x "*.log"` |
| `-1` | Fast compression | `zip -1 backup.zip large.txt` |
| `-9` | Maximum compression | `zip -9 backup.zip large.txt` |

> Command line mein password directly na likhein. `-e` use karein taa-ke password prompt ke zariye enter ho aur shell history mein save na ho.

---

## 8. Files exclude karna

Sab `.log` files exclude karein:

```bash
zip -r project.zip project/ -x "*.log"
```

Git directory exclude karein:

```bash
zip -r project.zip project/ -x "*/.git/*"
```

Multiple patterns exclude karein:

```bash
zip -r project.zip project/ -x "*.log" "*.tmp" "*/.git/*"
```

Patterns ko quote karna zaroori hai taa-ke shell unhein `zip` se pehle expand na kare.

---

## 9. Archive ko list, test aur extract karna

### Contents dekhein

```bash
unzip -l backup.zip
```

### Archive test karein

```bash
unzip -t backup.zip
```

Successful archive ke end par aam tor par yeh message milta hai:

```text
No errors detected in compressed data
```

### Current directory mein extract karein

```bash
unzip backup.zip
```

### Specific directory mein extract karein

```bash
unzip backup.zip -d restored-files/
```

### Existing files overwrite na karein

```bash
unzip -n backup.zip
```

---

## 10. Timestamped backup script

Suggested script name:

```text
create_zip_backup.sh
```

Script:

```bash
#!/bin/bash

source_dir="${1:-documents}"
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
archive="backup_${timestamp}.zip"

if [[ ! -d "$source_dir" ]]; then
    echo "Error: directory does not exist: $source_dir" >&2
    exit 1
fi

if zip -r "$archive" "$source_dir"; then
    echo "Backup created successfully: $archive"
    exit 0
else
    echo "Error: backup could not be created." >&2
    exit 1
fi
```

Executable banayein:

```bash
chmod +x create_zip_backup.sh
```

Default `documents/` directory ka backup:

```bash
./create_zip_backup.sh
```

Kisi aur directory ka backup:

```bash
./create_zip_backup.sh project/
```

### Script flow

1. Pehla argument source directory ke taur par leta hai.
2. Argument na mile to `documents` default value use hoti hai.
3. Current date aur time se unique archive name banta hai.
4. `[[ ! -d ... ]]` source directory verify karta hai.
5. `zip` successful ho to exit code `0` milta hai.
6. Failure par error standard error par aur exit code `1` milta hai.

---

## 11. Useful verification commands

```bash
ls -lh *.zip
file backup.zip
unzip -l backup.zip
unzip -t backup.zip
```

- `ls -lh` archive ka readable size dikhata hai.
- `file` file type identify karta hai.
- `unzip -l` contents list karta hai.
- `unzip -t` archive integrity test karta hai.

---

## 12. Common mistakes

### Directory ke saath `-r` bhool jana

Wrong:

```bash
zip backup.zip documents/
```

Correct:

```bash
zip -r backup.zip documents/
```

### Archive aur source ki position ulat dena

Correct order:

```bash
zip backup.zip file1.txt file2.txt
```

### Timestamp ko single quotes mein likhna

Wrong:

```bash
zip -r 'backup_$(date +%F).zip' documents/
```

Single quotes command substitution ko run nahi hone detin.

Correct:

```bash
zip -r "backup_$(date +%F).zip" documents/
```

### ZIP create karne ke baad verify na karna

```bash
unzip -t backup.zip
```

---

## 13. Quick-reference cheat sheet

```bash
# Install on Ubuntu/WSL
sudo apt install zip unzip -y

# One file
zip backup.zip file.txt

# Multiple files
zip backup.zip file1.txt file2.txt

# Directory
zip -r backup.zip documents/

# Timestamped directory archive
zip -r "backup_$(date +%Y-%m-%d_%H-%M-%S).zip" documents/

# Exclude log files
zip -r backup.zip documents/ -x "*.log"

# List contents
unzip -l backup.zip

# Test archive
unzip -t backup.zip

# Extract here
unzip backup.zip

# Extract into another directory
unzip backup.zip -d restored-files/
```

---

## 14. Practical question: `/etc` ka compressed backup

### Improved question

**Using the `tar` command, create compressed backups of the `/etc` directory with each of the following compression methods: `gzip`, `bzip2`, and `xz`. Save the resulting archives in `/root` using the correct filename extension. After creating each archive, verify its file type and list its contents without extracting it.**

Required archive names:

```text
/root/etc_backup.tar.gz
/root/etc_backup.tar.bz2
/root/etc_backup.tar.xz
```

**Roman Urdu:** `tar` command use karte hue `/etc` directory ke teen compressed backups banayein: aik `gzip`, doosra `bzip2`, aur teesra `xz` compression ke saath. Har archive ko `/root` mein correct extension ke saath save karein. Phir har archive ka file type verify karein aur usay extract kiye baghair uske contents list karein.

> `/root` mein file banane aur `/etc` ki tamam readable files access karne ke liye root privileges chahiye, is liye commands ke saath `sudo` use kiya gaya hai.

---

## 15. Required packages install karein

### RHEL, Rocky Linux, AlmaLinux ya Fedora

```bash
sudo dnf install tar gzip bzip2 xz -y
```

### Ubuntu, Debian ya WSL Ubuntu

```bash
sudo apt update
sudo apt install tar gzip bzip2 xz-utils -y
```

Verify karein:

```bash
tar --version
gzip --version
bzip2 --version
xz --version
```

---

## 16. `tar` ke important options

| Option | Long option | Kaam |
|---|---|---|
| `-c` | `--create` | Nayi archive create karta hai |
| `-v` | `--verbose` | Process hone wali files dikhata hai |
| `-f` | `--file` | Archive filename specify karta hai |
| `-z` | `--gzip` | Gzip compression use karta hai |
| `-j` | `--bzip2` | Bzip2 compression use karta hai |
| `-J` | `--xz` | XZ compression use karta hai |
| `-t` | `--list` | Archive ke contents list karta hai |
| `-x` | `--extract` | Archive extract karta hai |
| `-C` | `--directory` | Command chalane se pehle specified directory mein jata hai |

Common group:

```text
c + z/j/J + v + f
```

- `c` archive create karta hai.
- `z`, `j`, ya `J` compression method choose karta hai.
- `v` files screen par dikhata hai.
- `f` ke foran baad archive filename aata hai.

---

## 17. Gzip-compressed TAR archive (`.tar.gz`)

### Short-option command

```bash
sudo tar -czvf /root/etc_backup.tar.gz -C / etc
```

### Long-option command

```bash
sudo tar --gzip -cvf /root/etc_backup.tar.gz -C / etc
```

Verify file type:

```bash
sudo file /root/etc_backup.tar.gz
```

Contents extract kiye baghair list karein:

```bash
sudo tar -tzvf /root/etc_backup.tar.gz
```

---

## 18. Bzip2-compressed TAR archive (`.tar.bz2`)

### Short-option command

```bash
sudo tar -cjvf /root/etc_backup.tar.bz2 -C / etc
```

### Long-option command

```bash
sudo tar --bzip2 -cvf /root/etc_backup.tar.bz2 -C / etc
```

Verify file type:

```bash
sudo file /root/etc_backup.tar.bz2
```

Contents list karein:

```bash
sudo tar -tjvf /root/etc_backup.tar.bz2
```

> Bzip2 archive ka correct extension `.tar.bz2` hai, `.tar.gz` nahi.

---

## 19. XZ-compressed TAR archive (`.tar.xz`)

### Short-option command

```bash
sudo tar -cJvf /root/etc_backup.tar.xz -C / etc
```

### Long-option command

```bash
sudo tar --xz -cvf /root/etc_backup.tar.xz -C / etc
```

Verify file type:

```bash
sudo file /root/etc_backup.tar.xz
```

Contents list karein:

```bash
sudo tar -tJvf /root/etc_backup.tar.xz
```

> XZ archive ka correct extension `.tar.xz` hai, `.tar.gz` nahi.

---

## 20. `-C / etc` kyun use kiya?

Yeh command bhi archive bana sakti hai:

```bash
sudo tar -czvf /root/etc_backup.tar.gz /etc
```

Lekin `tar` aam tor par yeh warning dikhata hai:

```text
tar: Removing leading `/' from member names
```

Is liye yeh form zyada clean hai:

```bash
sudo tar -czvf /root/etc_backup.tar.gz -C / etc
```

- `-C /` pehle root directory `/` mein jata hai.
- `etc` archive mein relative path ke taur par store hota hai.
- Archive ke andar `/etc/...` ke bajaye `etc/...` entries hoti hain.
- Relative paths ke saath restore karna zyada controlled aur safe hota hai.

---

## 21. Archive ko safely extract karna

Pehle separate restore directory banayein:

```bash
sudo mkdir -p /root/etc_restore
```

### Gzip archive

```bash
sudo tar -xzvf /root/etc_backup.tar.gz -C /root/etc_restore
```

### Bzip2 archive

```bash
sudo tar -xjvf /root/etc_backup.tar.bz2 -C /root/etc_restore
```

### XZ archive

```bash
sudo tar -xJvf /root/etc_backup.tar.xz -C /root/etc_restore
```

> Practice ke dauran archive ko seedha `/` par extract na karein. Is se current `/etc` configuration files overwrite ho sakti hain.

---

## 22. `tar`, `gzip`, `bzip2`, `xz` aur `zip` ka farq

| Tool | Main purpose | Directory directly? | Common extension |
|---|---|---:|---|
| `tar` | Multiple files ko aik archive mein jama karna | Haan | `.tar` |
| `gzip` | Single data stream/file compress karna | Nahi | `.gz` |
| `bzip2` | Single data stream/file compress karna | Nahi | `.bz2` |
| `xz` | Single data stream/file compress karna | Nahi | `.xz` |
| `zip` | Archiving aur compression dono | Haan, `-r` ke saath | `.zip` |

Directory ko `gzip`, `bzip2`, ya `xz` ke saath compress karne ke liye pehle `tar` multiple files ko archive karta hai; phir selected compressor us archive ko compress karta hai.

```text
/etc directory → tar archive → gzip/bzip2/xz compression
```

---

## 23. Extra `gzip` aur `gunzip` notes

### File compress karein aur original bhi rakhein

```bash
gzip -k file.txt
```

Result:

```text
file.txt
file.txt.gz
```

`-k` ka matlab `--keep` hai. Is ke baghair `gzip file.txt` aam tor par original file ko `file.txt.gz` se replace kar deta hai.

### Gzip file decompress karein

```bash
gunzip file.txt.gz
```

Equivalent command:

```bash
gzip -d file.txt.gz
```

Compressed file ko bhi preserve karna ho:

```bash
gunzip -k file.txt.gz
```

> `gzip` directory ko directly recursively archive nahi karta. Directory ke liye `tar -czf` use karein.

---

## 24. Extra `zip` aur `unzip` notes

### Multiple files ko aik ZIP archive mein compress karein

```bash
zip myfiles.zip f1 f2
```

Yahan `f1` aur `f2` dono aik hi `myfiles.zip` archive mein store honge.

### ZIP archive ke contents list karein

```bash
unzip -l myfiles.zip
```

### ZIP archive test karein

```bash
unzip -t myfiles.zip
```

### ZIP archive extract karein

```bash
unzip myfiles.zip
```

---

## 25. Compression quick comparison

| Format | Tar option | Speed | Typical compression | Filename |
|---|---|---|---|---|
| Gzip | `-z` | Fast | Good | `.tar.gz` |
| Bzip2 | `-j` | Slower | Often better than gzip | `.tar.bz2` |
| XZ | `-J` | Usually slowest | Often smallest archive | `.tar.xz` |

Actual speed aur archive size data type, CPU aur available memory par depend karte hain.

---

## 26. TAR backup quick-reference

```bash
# Install on RHEL-family systems
sudo dnf install tar gzip bzip2 xz -y

# Install on Ubuntu/WSL
sudo apt install tar gzip bzip2 xz-utils -y

# /etc with gzip
sudo tar -czvf /root/etc_backup.tar.gz -C / etc

# /etc with bzip2
sudo tar -cjvf /root/etc_backup.tar.bz2 -C / etc

# /etc with xz
sudo tar -cJvf /root/etc_backup.tar.xz -C / etc

# Verify types
sudo file /root/etc_backup.tar.gz
sudo file /root/etc_backup.tar.bz2
sudo file /root/etc_backup.tar.xz

# List without extracting
sudo tar -tzvf /root/etc_backup.tar.gz
sudo tar -tjvf /root/etc_backup.tar.bz2
sudo tar -tJvf /root/etc_backup.tar.xz
```

## Short summary

`zip` multiple files aur directories ko aik compressed archive mein rakhta hai. `tar` archiving karta hai aur `-z`, `-j`, ya `-J` ke zariye gzip, bzip2, ya xz compression use kar sakta hai. Correct extensions `.tar.gz`, `.tar.bz2`, aur `.tar.xz` hain. Backup ko successful samajhne se pehle `file`, `tar -t...`, ya `unzip -t` se verify karna achhi practice hai.
