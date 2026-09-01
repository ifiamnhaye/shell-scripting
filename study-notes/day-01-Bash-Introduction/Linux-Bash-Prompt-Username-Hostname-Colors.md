# Linux Bash Prompt: Change Username and Hostname Colors

## Objective

Configure the Bash prompt so that:

- **Username** appears in green.
- **Hostname** appears in red.
- **Current directory** appears in blue.
- The remaining prompt uses the terminal's default color.

Example prompt:

```text
[root@PracticeLab ~]#
```

## Temporary configuration

Run this command to test the colored prompt in the current shell:

```bash
export PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \[\e[34m\]\W\[\e[0m\]]\$ '
```

This change remains active only until you close the current terminal or log out.

## Permanent configuration for the root user

### 1. Create a backup of `.bashrc`

```bash
cp /root/.bashrc /root/.bashrc.backup
```

### 2. Open the root user's `.bashrc` file

```bash
vi /root/.bashrc
```

### 3. Add these lines at the end of the file

```bash
PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \[\e[34m\]\W\[\e[0m\]]\$ '
export PS1
```

### 4. Apply the configuration

```bash
source /root/.bashrc
```

You can also log out and log back in to load the updated configuration.

## Permanent configuration for a regular user

Log in as that user and edit their own `.bashrc` file:

```bash
vi ~/.bashrc
```

Add:

```bash
PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \[\e[34m\]\W\[\e[0m\]]\$ '
export PS1
```

Apply it:

```bash
source ~/.bashrc
```

## Meaning of the prompt symbols

| Symbol | Meaning |
|---|---|
| `\u` | Current username |
| `\h` | Short hostname |
| `\H` | Full hostname |
| `\W` | Current directory name only |
| `\w` | Complete current directory path |
| `\$` | Displays `#` for root and `$` for a regular user |

## ANSI color codes

| Code | Color |
|---:|---|
| `30` | Black |
| `31` | Red |
| `32` | Green |
| `33` | Yellow |
| `34` | Blue |
| `35` | Magenta |
| `36` | Cyan |
| `37` | White |
| `0` | Reset to the terminal's default color |

## Understanding the complete `PS1` value

```bash
PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \[\e[34m\]\W\[\e[0m\]]\$ '
```

| Part | Purpose |
|---|---|
| `\[\e[32m\]` | Start green color |
| `\u` | Display the username |
| `\[\e[0m\]` | Reset the color |
| `@` | Display the `@` character |
| `\[\e[31m\]` | Start red color |
| `\h` | Display the short hostname |
| `\[\e[34m\]` | Start blue color |
| `\W` | Display the current directory name |
| `\$` | Display `#` for root or `$` for a regular user |

The `\[` and `\]` markers tell Bash that the enclosed color codes do not occupy visible screen space. They prevent cursor-position and command-line wrapping problems.

## Show the complete directory path

Replace `\W` with `\w`:

```bash
PS1='[\[\e[32m\]\u\[\e[0m\]@\[\e[31m\]\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]]\$ '
```

Example:

```text
[root@PracticeLab /etc/httpd/conf]#
```

## Restore the original root configuration

If the prompt configuration causes a problem, restore the backup:

```bash
cp /root/.bashrc.backup /root/.bashrc
source /root/.bashrc
```

## Important note

Use `/root/.bashrc` only for the root user's personal configuration. Use `~/.bashrc` for the currently logged-in user's configuration. Avoid changing `/etc/bashrc` unless you intentionally want the prompt change to affect multiple users system-wide.
