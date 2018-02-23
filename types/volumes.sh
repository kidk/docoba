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

        # Generate random name to use as container name
        UUID=backup-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

        # Perform backup in container
        echo "# Creating backup file"
        docker run --name=$UUID -v $src:/src:ro busybox tar -zcvf /backup.tar.gz /src

        # Find current container id
        CPARENT=$(cat /etc/hostname)

        # Copy backup from child to host /tmp
        echo "Moving backup from child container to host"
        docker cp $UUID:/backup.tar.gz /tmp/$UUID.tar.gz

        # Copy back from host /tmp to parent
        echo "Moving host to parent container"
        docker cp /tmp/$UUID.tar.gz $CPARENT:$dest

        # Clean up child and backup in /tmp
        echo "Cleaning up"
        rm /tmp/$UUID.tar.gz
        docker rm $UUID
    done
done
