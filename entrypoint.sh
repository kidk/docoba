#!/usr/bin/env bash

set -e

# Prepare root backup
export ROOT=backup
mkdir -p $ROOT

# MySQL
echo "---------------------"
echo "       MySQL         "
echo "---------------------"
./types/mysql.sh

# Volumes
echo "---------------------"
echo "      Volumes        "
echo "---------------------"
./types/volumes.sh

# Zip
echo "---------------------"
echo "      Compress       "
echo "---------------------"
FILENAME="backup-`date +%Y%m%d`.tar.gz"
tar -zcvf $FILENAME $ROOT/

# Upload to AWS
echo "---------------------"
echo "      Upload         "
echo "---------------------"
/usr/bin/aws s3 cp --storage-class "$AWS_S3_STORAGE_CLASS" $FILENAME s3://$AWS_S3_BUCKET
