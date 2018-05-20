#!/usr/bin/env bash

# Check if we need to do filesystem backups
if [ ! -z "$FILESYSTEM_BACKUP" ]; then

    # Get directories to backup
    directories=$(echo $FILESYSTEM_BACKUP | tr ":" "\n")

    # Prepare destination
    ROOT=$ROOT/host
    mkdir -p "$ROOT"

    # Backup directories
    for directory in $directories; do

        # Output and prepare
        echo "Backup of host directory $directory to $ROOT/"

        # Copy directory files
        cp --parents -R "/host$directory" /backup/

    done
fi
