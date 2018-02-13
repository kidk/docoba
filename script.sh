
ROOT=./backup
mkdir $ROOT

# Create a list of all containers we need to backup
# This is done by looking for containers with label MYSQL_BACKUP=true
containers=$(docker ps -q --filter "label=MYSQL_BACKUP=true")

# Loop list and take backups
for id in $containers; do
    # Get container name
    name=$(docker ps --filter "id=$id" --format "{{.Names}}")
    echo "Preparing backup for $name"
    mkdir $ROOT/$name/

    # Get MySQL credentials
    username=root
    password=$(docker exec $id bash -c 'echo $MYSQL_ROOT_PASSWORD')

    # Might be using MYSQL_RANDOM_ROOT_PASSWORD, try to find it in logs
    if [ -z "$password" ]; then
        password=$(docker logs $id 2>&1 | grep 'GENERATED ROOT PASSWORD' | awk '{print $NF}')
    fi

    # Worst case we use MYSQL_USERNAME and MYSQL_PASSWORD
    if [ -z "$password" ]; then
        username=$(docker exec $id bash -c 'echo $MYSQL_USERNAME')
        password=$(docker exec $id bash -c 'echo $MYSQL_PASSWORD')
    fi

    # Retrieve list of databases
    databases=$(docker exec $id mysql -uroot -p$password -e "SHOW DATABASES;" | grep -v Database)
    for database in $databases; do
        if [[ "$database" != "information_schema" ]] && [[ "$database" != "performance_schema" ]] && [[ "$database" != "mysql" ]] && [[ "$database" != _* ]] ; then
            echo "Dumping database: $database"
            docker exec $id mysqldump -uroot -p$password --databases $database > $ROOT/$name/`date +%Y%m%d`.$database.sql
        fi
    done
done

# Zip
FILENAME="backup-`date +%Y%m%d`.tar.gz"
tar -zcvf $FILENAME $ROOT/

# Upload to AWS
/usr/local/bin/aws s3 cp --storage-class "$AWS_S3_STORAGE_CLASS" $FILENAME s3://$AWS_S3_BUCKET
