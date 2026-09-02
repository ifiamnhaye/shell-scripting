#!/bin/bash

function display_usage {
    echo "Usage: ./backup.sh <path to your source> <path to backup folder>"
}

if [ $# -ne 2 ]; then
    display_usage
    exit 1
fi

source_dir="$1"
backup_dir="$2"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

function create_backup {

    if zip -r "${backup_dir}/backup_${timestamp}.zip" "$source_dir"; then
        echo "Backup generated successfully for ${timestamp}"
    else
        echo "Backup failed"
        exit 1
    fi
}

function perform_rotation {

    backups=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null))

    if [ "${#backups[@]}" -gt 5 ]; then

        echo "Performing rotation. Keeping latest 5 backups."

        backups_to_remove=("${backups[@]:5}")

        echo "Backups to remove:"
        printf '%s\n' "${backups_to_remove[@]}"

        for backup in "${backups_to_remove[@]}"; do
            echo "Removing: $backup"
            rm -f -- "$backup"
        done

    else
        echo "Rotation not required. Total backups: ${#backups[@]}"
    fi
}

create_backup
perform_rotation
