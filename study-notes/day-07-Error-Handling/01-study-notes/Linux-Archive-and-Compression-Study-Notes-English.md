# Linux Archive and Compression — `zip`, `tar`, `gzip`, `bzip2`, and `xz`

## 1. What is an archive?

An **archive** is a single file that contains multiple files and directories.

```text
file1.txt + file2.txt + documents/  →  backup archive
```

| Term | Meaning |
|---|---|
| Archive | Combine multiple files and directories into one container |
| Compression | Reduce the amount of storage used by data |
| Extraction | Restore files from an archive |

An archive is not always compressed. For example, `.tar` is normally an uncompressed archive, while `.tar.gz` is a TAR archive compressed with gzip.

---

## 2. What is `zip`?

The `zip` command combines files and directories into a `.zip` archive and normally compresses them at the same time.

```bash
zip backup.zip file1.txt file2.txt
```

ZIP is commonly used when sharing files between Linux, Windows, and macOS.

---

## 3. Install ZIP tools

### Ubuntu, Debian, or WSL Ubuntu

```bash
sudo apt update
sudo apt install zip unzip -y
```

### RHEL, Rocky Linux, AlmaLinux, or Fedora

```bash
sudo dnf install zip unzip -y
```

Verify the installation:

```bash
zip --version
unzip -v
```

---

## 4. Solving `No manual entry for zip`

If this command:

```bash
man zip
```

returns:

```text
No manual entry for zip
```

first check whether `zip` is installed:

```bash
command -v zip
zip --version
```

On Ubuntu or WSL, reinstall the package and rebuild the manual-page database:

```bash
sudo apt install --reinstall zip man-db -y
sudo mandb
man zip
```

For quick help without a manual page:

```bash
zip --help
```

---

## 5. ZIP command syntax

```bash
zip [options] archive-name.zip source...
```

Example:

```bash
zip backup.zip file1.txt file2.txt
```

| Part | Purpose |
|---|---|
| `zip` | Command |
| `backup.zip` | Archive to create or update |
| `file1.txt file2.txt` | Source files |

The archive name comes before the source files.

---

## 6. Basic ZIP examples

### Archive one file

```bash
zip backup.zip file1.txt
```

### Archive multiple files

```bash
zip backup.zip file1.txt file2.txt file3.txt
```

### Archive a directory

Use `-r` to include the directory and everything below it recursively:

```bash
zip -r project.zip project/
```

### Archive files and directories together

```bash
zip -r backup.zip file1.txt file2.txt documents/
```

---

## 7. Add a timestamp to a ZIP archive

### Question

**How can I add a date and time (timestamp) to the filename of a ZIP archive in Linux?**

### Answer

Use command substitution with the `date` command:

```bash
zip -r "backup_$(date +%Y-%m-%d_%H-%M-%S).zip" documents/
```

Possible filename:

```text
backup_2026-08-17_15-45-30.zip
```

### Date-format reference

| Format | Meaning | Example |
|---|---|---|
| `%Y` | Four-digit year | `2026` |
| `%m` | Month | `08` |
| `%d` | Day | `17` |
| `%H` | Hour in 24-hour format | `15` |
| `%M` | Minute | `45` |
| `%S` | Second | `30` |

Use hyphens instead of colons in filenames, especially when an archive might be shared with Windows.

### Use only the date

```bash
zip -r "backup_$(date +%Y-%m-%d).zip" documents/
```

### Use variables for readability

```bash
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
archive="backup_${timestamp}.zip"

zip -r "$archive" documents/

echo "Archive created: $archive"
```

Double quotes protect filenames from word splitting and special-character problems.

---

## 8. Common ZIP options

| Option | Purpose | Example |
|---|---|---|
| `-r` | Recursively include a directory | `zip -r project.zip project/` |
| `-q` | Hide normal output | `zip -q backup.zip file.txt` |
| `-u` | Add only new or updated files | `zip -u backup.zip file.txt` |
| `-d` | Delete a matching file from an archive | `zip -d backup.zip file.txt` |
| `-e` | Prompt for a password and encrypt | `zip -e private.zip file.txt` |
| `-x` | Exclude matching files | `zip -r project.zip project/ -x "*.log"` |
| `-1` | Use fast compression | `zip -1 backup.zip large.txt` |
| `-9` | Use maximum compression | `zip -9 backup.zip large.txt` |

Do not place a password directly in a command. Use `-e` so it is entered at a prompt and does not appear in shell history.

---

## 9. Exclude files from a ZIP archive

Exclude all `.log` files:

```bash
zip -r project.zip project/ -x "*.log"
```

Exclude Git metadata:

```bash
zip -r project.zip project/ -x "*/.git/*"
```

Exclude multiple patterns:

```bash
zip -r project.zip project/ -x "*.log" "*.tmp" "*/.git/*"
```

Quote the patterns so the shell does not expand them before `zip` receives them.

---

## 10. List, test, and extract ZIP archives

### List contents without extracting

```bash
unzip -l backup.zip
```

### Test archive integrity

```bash
unzip -t backup.zip
```

A successful test normally ends with:

```text
No errors detected in compressed data
```

### Extract into the current directory

```bash
unzip backup.zip
```

### Extract into another directory

```bash
unzip backup.zip -d restored-files/
```

### Do not overwrite existing files

```bash
unzip -n backup.zip
```

---

## 11. Timestamped ZIP backup script

Suggested script name:

```text
create_zip_backup.sh
```

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

Make it executable:

```bash
chmod +x create_zip_backup.sh
```

Back up the default `documents/` directory:

```bash
./create_zip_backup.sh
```

Back up a different directory:

```bash
./create_zip_backup.sh project/
```

### Script flow

1. The first argument is used as the source directory.
2. If no argument is supplied, `documents` is used as the default.
3. The current date and time create a unique archive name.
4. `[[ ! -d ... ]]` checks whether the source directory exists.
5. A successful `zip` command produces exit status `0`.
6. A failure sends an error to standard error and exits with status `1`.

---

## 12. ZIP verification commands

```bash
ls -lh *.zip
file backup.zip
unzip -l backup.zip
unzip -t backup.zip
```

- `ls -lh` displays a human-readable archive size.
- `file` identifies the file type.
- `unzip -l` lists the contents.
- `unzip -t` checks archive integrity.

---

## 13. Common ZIP mistakes

### Forgetting `-r` for a directory

Incorrect:

```bash
zip backup.zip documents/
```

Correct:

```bash
zip -r backup.zip documents/
```

### Reversing the archive and source positions

Correct order:

```bash
zip backup.zip file1.txt file2.txt
```

### Placing command substitution inside single quotes

Incorrect:

```bash
zip -r 'backup_$(date +%F).zip' documents/
```

Single quotes prevent command substitution.

Correct:

```bash
zip -r "backup_$(date +%F).zip" documents/
```

### Failing to verify the archive

```bash
unzip -t backup.zip
```

---

## 14. Practical task: Compress `/etc` with TAR

### Improved question

**Using the `tar` command, create compressed backups of the `/etc` directory with each of the following compression methods: `gzip`, `bzip2`, and `xz`. Save the resulting archives in `/root` using the correct filename extension. After creating each archive, verify its file type and list its contents without extracting it.**

Required archive names:

```text
/root/etc_backup.tar.gz
/root/etc_backup.tar.bz2
/root/etc_backup.tar.xz
```

The `/root` destination and some files under `/etc` require root privileges, so the examples use `sudo`.

---

## 15. Install TAR and compression tools

### RHEL, Rocky Linux, AlmaLinux, or Fedora

```bash
sudo dnf install tar gzip bzip2 xz -y
```

### Ubuntu, Debian, or WSL Ubuntu

```bash
sudo apt update
sudo apt install tar gzip bzip2 xz-utils -y
```

Verify the tools:

```bash
tar --version
gzip --version
bzip2 --version
xz --version
```

---

## 16. Important TAR options

| Short option | Long option | Purpose |
|---|---|---|
| `-c` | `--create` | Create a new archive |
| `-v` | `--verbose` | Display files being processed |
| `-f` | `--file` | Specify the archive filename |
| `-z` | `--gzip` | Use gzip compression |
| `-j` | `--bzip2` | Use bzip2 compression |
| `-J` | `--xz` | Use XZ compression |
| `-t` | `--list` | List archive contents |
| `-x` | `--extract` | Extract an archive |
| `-C` | `--directory` | Change to a directory before processing |

Common creation pattern:

```text
c + z/j/J + v + f
```

- `c` creates the archive.
- `z`, `j`, or `J` selects the compression method.
- `v` displays processed files.
- `f` indicates that the archive filename follows.

---

## 17. Create a gzip-compressed TAR archive (`.tar.gz`)

### Short options

```bash
sudo tar -czvf /root/etc_backup.tar.gz -C / etc
```

### Long compression option

```bash
sudo tar --gzip -cvf /root/etc_backup.tar.gz -C / etc
```

Verify its file type:

```bash
sudo file /root/etc_backup.tar.gz
```

List its contents without extracting:

```bash
sudo tar -tzvf /root/etc_backup.tar.gz
```

---

## 18. Create a bzip2-compressed TAR archive (`.tar.bz2`)

### Short options

```bash
sudo tar -cjvf /root/etc_backup.tar.bz2 -C / etc
```

### Long compression option

```bash
sudo tar --bzip2 -cvf /root/etc_backup.tar.bz2 -C / etc
```

Verify its file type:

```bash
sudo file /root/etc_backup.tar.bz2
```

List its contents:

```bash
sudo tar -tjvf /root/etc_backup.tar.bz2
```

The correct bzip2 extension is `.tar.bz2`, not `.tar.gz`.

---

## 19. Create an XZ-compressed TAR archive (`.tar.xz`)

### Short options

```bash
sudo tar -cJvf /root/etc_backup.tar.xz -C / etc
```

### Long compression option

```bash
sudo tar --xz -cvf /root/etc_backup.tar.xz -C / etc
```

Verify its file type:

```bash
sudo file /root/etc_backup.tar.xz
```

List its contents:

```bash
sudo tar -tJvf /root/etc_backup.tar.xz
```

The correct XZ extension is `.tar.xz`, not `.tar.gz`.

---

## 20. Why use `-C / etc`?

This command can also create the archive:

```bash
sudo tar -czvf /root/etc_backup.tar.gz /etc
```

However, TAR will normally display:

```text
tar: Removing leading `/' from member names
```

The following form is cleaner:

```bash
sudo tar -czvf /root/etc_backup.tar.gz -C / etc
```

- `-C /` changes to the root directory before processing.
- `etc` is stored as a relative path.
- Archive members appear as `etc/...` instead of `/etc/...`.
- Relative archive paths make controlled restoration safer.

---

## 21. Extract TAR archives safely

Create a separate restoration directory:

```bash
sudo mkdir -p /root/etc_restore
```

### Extract the gzip archive

```bash
sudo tar -xzvf /root/etc_backup.tar.gz -C /root/etc_restore
```

### Extract the bzip2 archive

```bash
sudo tar -xjvf /root/etc_backup.tar.bz2 -C /root/etc_restore
```

### Extract the XZ archive

```bash
sudo tar -xJvf /root/etc_backup.tar.xz -C /root/etc_restore
```

Do not extract an `/etc` backup directly into `/` during practice. It could overwrite the system's current configuration files.

---

## 22. Difference between TAR, gzip, bzip2, XZ, and ZIP

| Tool | Main purpose | Directories directly? | Common extension |
|---|---|---:|---|
| `tar` | Combine multiple files into one archive | Yes | `.tar` |
| `gzip` | Compress one data stream or file | No | `.gz` |
| `bzip2` | Compress one data stream or file | No | `.bz2` |
| `xz` | Compress one data stream or file | No | `.xz` |
| `zip` | Archive and compress | Yes, with `-r` | `.zip` |

To compress a directory with gzip, bzip2, or XZ, TAR first creates an archive and the selected compressor then compresses that archive.

```text
/etc directory → TAR archive → gzip/bzip2/XZ compression
```

---

## 23. Additional `gzip` and `gunzip` notes

### Compress a file while keeping the original

```bash
gzip -k file.txt
```

Result:

```text
file.txt
file.txt.gz
```

`-k` means `--keep`. Without it, `gzip file.txt` normally replaces the original file with `file.txt.gz`.

### Decompress a gzip file

```bash
gunzip file.txt.gz
```

Equivalent command:

```bash
gzip -d file.txt.gz
```

Keep the compressed file as well:

```bash
gunzip -k file.txt.gz
```

`gzip` does not directly archive a directory. Use `tar -czf` for a directory.

---

## 24. Additional `zip` and `unzip` notes

### Compress multiple files together

```bash
zip myfiles.zip f1 f2
```

Both `f1` and `f2` are stored in `myfiles.zip`.

### List ZIP contents

```bash
unzip -l myfiles.zip
```

### Test the ZIP archive

```bash
unzip -t myfiles.zip
```

### Extract the ZIP archive

```bash
unzip myfiles.zip
```

---

## 25. Compression comparison

| Format | TAR option | Relative speed | Typical compression | Filename |
|---|---|---|---|---|
| Gzip | `-z` | Fast | Good | `.tar.gz` |
| Bzip2 | `-j` | Slower | Often better than gzip | `.tar.bz2` |
| XZ | `-J` | Usually slowest | Often produces the smallest archive | `.tar.xz` |

Actual speed and archive size depend on the data, CPU, and available memory.

---

## 26. Quick-reference cheat sheet

```bash
# Install on RHEL-family systems
sudo dnf install tar gzip bzip2 xz zip unzip -y

# Install on Ubuntu/WSL
sudo apt install tar gzip bzip2 xz-utils zip unzip -y

# Create a timestamped ZIP archive
zip -r "backup_$(date +%Y-%m-%d_%H-%M-%S).zip" documents/

# Create /etc backup with gzip
sudo tar -czvf /root/etc_backup.tar.gz -C / etc

# Create /etc backup with bzip2
sudo tar -cjvf /root/etc_backup.tar.bz2 -C / etc

# Create /etc backup with XZ
sudo tar -cJvf /root/etc_backup.tar.xz -C / etc

# Verify file types
sudo file /root/etc_backup.tar.gz
sudo file /root/etc_backup.tar.bz2
sudo file /root/etc_backup.tar.xz

# List TAR contents without extracting
sudo tar -tzvf /root/etc_backup.tar.gz
sudo tar -tjvf /root/etc_backup.tar.bz2
sudo tar -tJvf /root/etc_backup.tar.xz

# ZIP operations
zip myfiles.zip f1 f2
unzip -l myfiles.zip
unzip -t myfiles.zip
unzip myfiles.zip

# Gzip one file and keep the original
gzip -k file.txt

# Decompress gzip
gunzip file.txt.gz
```

## Summary

`zip` combines files and directories into a compressed `.zip` archive. TAR combines files into an archive and can use `-z`, `-j`, or `-J` for gzip, bzip2, or XZ compression. The correct extensions are `.tar.gz`, `.tar.bz2`, and `.tar.xz`. Always verify important backups using `file`, `tar -t...`, or `unzip -t` before relying on them.
