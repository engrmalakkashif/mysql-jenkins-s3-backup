#!/bin/bash
set -e

echo "============================="
echo "=== MYSQL DATABASE BACKUP ==="
echo "============================="

DB_USER="$1"
DB_PASSWORD="$2"
DB_NAME="$3"
S3_BUCKET_NAME="$4"
ACCESS_KEY_ID="$5"
SECRET_ACCESS_KEY="$6"

DATETIME=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE_NAME="${DB_NAME}_${DATETIME}.sql"

echo "[+] Creating MySQL Dump..."
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_FILE_NAME"

echo "[+] Setting AWS Credentials..."
export AWS_ACCESS_KEY_ID="$ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="eu-central-1"

echo "[+] Uploading to S3: $S3_BUCKET_NAME"
aws s3 cp "$BACKUP_FILE_NAME" "s3://$S3_BUCKET_NAME/"

echo "[✔] Backup Complete!"
