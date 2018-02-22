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

    # Retrieve project name (composer support)
    project=$(docker inspect --format "{{ index .Config.Labels \"com.docker.compose.project\"}}" $name | tr -d '\n')

    # Backup volumes
    for volume in $volumes; do
        # Prepare src, dest
        dest=$ROOT/$name/volumes/$volume
        if [ -n "$project" ]; then
            src="${project}_${volume}"
        else
            src="$volume"
        fi

        # Output and prepare
        echo "Backup of $src to $dest"
        mkdir -p $dest

        # Perform copy in container
        docker run --rm -v $src:/src:ro -v $PWD/$dest:/dst busybox cp -av /src /dst
    done
done
