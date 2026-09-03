#!/bin/bash


# learning varible

timestamp=$(date '+%Y-%m-%d-%H-%M-%S')

echo "==============Create a new backup==============="

zip -rq backups/backup_"${timestamp}".zip data


echo "=======Load backups latest 5 ==================="

items=($(ls -t backups/backup_*.zip))

# printf '%s\n' "${items[@]}"

printf '%s\n' "${#items[@]}"

echo "========start Rotation=================="

if [[ "${#items[@]}" -gt 5 ]]; then

        echo "===========Backups to remove========"
        backups_to_remove=("${items[@]:5}")

        for backup in "${backups_to_remove[@]}";
                do
                        echo "Removing: ${backup}"
                        rm "${backup}"
                done

fi