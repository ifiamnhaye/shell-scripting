#!/bin/bash

function display_usage {
    echo "Usage: $0 <source_directory> <backup_directory> [keep_backups]"
    echo
    echo "Example:"
    echo "  $0 ./data ./backups"
    echo "  $0 ./data ./backups 10"
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
    display_usage
    exit 1
fi

source_dir="$1"
backup_dir="$2"
keep_backups="${3:-5}"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

if [[ ! -d "$source_dir" ]]; then
    echo "Error: Source directory does not exist:"
    echo "$source_dir"
    exit 1
fi

if ! [[ "$keep_backups" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: keep_backups must be a positive integer."
    echo "Example: 5, 10, 15"
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip command is not installed."
    echo "Install it first and run the script again."
    exit 1
fi

mkdir -p -- "$backup_dir"

function create_backup {

    backup_file="${backup_dir}/backup_${timestamp}.zip"

    echo "Creating backup..."
    echo "Source: $source_dir"
    echo "Destination: $backup_file"

    if zip -rq -- "$backup_file" "$source_dir"; then
        echo "Backup generated successfully."
        echo "Backup file: $backup_file"
    else
        echo "Backup failed."
        exit 1
    fi
}

function perform_rotation {

    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    echo
    echo "Total backups: ${#backups[@]}"
    echo "Backups to keep: $keep_backups"

    if [[ ${#backups[@]} -gt $keep_backups ]]; then

        echo
        echo "Performing backup rotation..."

        backups_to_keep=("${backups[@]:0:$keep_backups}")
        backups_to_remove=("${backups[@]:$keep_backups}")

        echo
        echo "Backups being kept:"
        printf '%s\n' "${backups_to_keep[@]}"

        echo
        echo "Backups to remove:"
        printf '%s\n' "${backups_to_remove[@]}"

        echo

        for backup in "${backups_to_remove[@]}"; do
            echo "Removing: $backup"
            rm -f -- "$backup"
        done

        echo
        echo "Backup rotation completed."

    else
        echo "Rotation not required."
    fi
}

create_backup
perform_rotation
