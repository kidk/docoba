#!/usr/bin/env bash

# Create a list of all containers we need to backup
# This is done by looking for containers with label
containers=$(docker ps -q --filter "label=VOLUME_BACKUP")

# Loop list and take backups
for id in $containers; do
    # Get container name
    name=$(docker ps --filter "id=$id" --format "{{.Names}}")
    echo "Preparing backup for $name"
    mkdir -p $ROOT/$name/volumes/

    # Get volumes to backup
    volumes=$(docker inspect --format "{{ index .Config.Labels \"VOLUME_BACKUP\"}}" $name | tr "," "\n")

    # Backup volumes
    for volume in $volumes; do
        dest=$ROOT/$name/volumes/$volume
        echo "Backup of $volume to $dest"
        mkdir -p $dest

        docker run --rm -v $volume:/src:ro -v $PWD/$dest:/dst busybox cp -av /src /dst
    done
done
