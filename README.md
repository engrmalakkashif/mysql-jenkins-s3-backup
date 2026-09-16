# 🚀 Automated MySQL Database Backup to AWS S3 Using Jenkins

This project demonstrates how to automate **MySQL database backups** using **Jenkins** and upload the generated SQL dump to an **Amazon S3 bucket**.

The Jenkins pipeline executes a Bash script that:

1. Creates a MySQL database dump.
2. Generates a timestamped backup file.
3. Configures AWS credentials.
4. Uploads the backup to an S3 bucket.
5. Reports the backup status in Jenkins.

---

## 🏗️ Architecture

```text
                 ┌──────────────────┐
                 │     Jenkins      │
                 │   CI/CD Server   │
                 └────────┬─────────┘
                          │
                          │ Execute Pipeline
                          ▼
                 ┌──────────────────┐
                 │ database_dump.sh │
                 └────────┬─────────┘
                          │
                          │ mysqldump
                          ▼
                 ┌──────────────────┐
                 │      MySQL       │
                 │    Database      │
                 └────────┬─────────┘
                          │
                          │ .sql backup
                          ▼
                 ┌──────────────────┐
                 │   Backup File    │
                 │ DB_YYYYMMDD.sql  │
                 └────────┬─────────┘
                          │
                          │ aws s3 cp
                          ▼
                 ┌──────────────────┐
                 │    AWS S3        │
                 │  Backup Bucket   │
                 └──────────────────┘
```

---

## 🛠️ Technologies Used

| Technology  | Purpose                           |
| ----------- | --------------------------------- |
| Jenkins     | Automation and pipeline execution |
| Bash        | Backup automation script          |
| MySQL       | Source database                   |
| `mysqldump` | Database backup                   |
| AWS CLI     | Upload backup to S3               |
| Amazon S3   | Backup storage                    |
| Linux       | Execution environment             |

---

## 📁 Project Structure

```text
mysql-s3-backup/
│
├── Jenkinsfile
├── database_dump.sh
└── README.md
```

### `Jenkinsfile`

Defines the Jenkins pipeline and passes database/AWS configuration to the backup script.

### `database_dump.sh`

Creates the MySQL dump and uploads it to Amazon S3.

---

# ⚙️ Prerequisites

Before running the project, make sure the Jenkins agent has the following installed:

### 1. Java

Jenkins requires Java.

```bash
java -version
```

### 2. Jenkins

Verify Jenkins is running:

```bash
sudo systemctl status jenkins
```

### 3. MySQL Client

Install the MySQL client:

```bash
sudo apt update
sudo apt install mysql-client -y
```

Verify:

```bash
mysqldump --version
```

### 4. AWS CLI

Install AWS CLI:

```bash
aws --version
```

The Jenkins agent must have permission to access the S3 bucket.

---

# 🪣 Create an S3 Bucket

Create an S3 bucket:

```bash
aws s3 mb s3://devops-db-backup --region eu-central-1
```

Verify:

```bash
aws s3 ls
```

You should see:

```text
devops-db-backup
```

---

# 🔐 AWS Credentials

The example pipeline contains:

```groovy
ACCESS_KEY_ID = 'AKIAXXXXXXXX'
SECRET_ACCESS_KEY = 'XXXXXXXXXXXXXXX'
```

**Do not use real AWS credentials directly inside a Jenkinsfile.**

This is only for demonstration.

For a real project, use:

* Jenkins Credentials
* AWS IAM Roles
* IAM policies with least privilege
* Jenkins credential bindings

For an EC2-based Jenkins agent, an **IAM Role** is generally preferable to storing long-lived access keys.

---

# 🗄️ Database Configuration

The pipeline currently defines:

```groovy
DB_USER = 'prod'
DB_PASSWORD = 'password'
DB_NAME = 'DummyDatabase'
```

These values are passed to:

```bash
database_dump.sh
```

The script receives:

```text
$1 → DB_USER
$2 → DB_PASSWORD
$3 → DB_NAME
$4 → S3_BUCKET_NAME
$5 → ACCESS_KEY_ID
$6 → SECRET_ACCESS_KEY
```

---

# 📜 Backup Script

The script creates a timestamp:

```bash
DATETIME=$(date +"%Y%m%d_%H%M%S")
```

Then generates a backup filename:

```bash
BACKUP_FILE_NAME=${DB_NAME}_${DATETIME}.sql
```

For example:

```text
DummyDatabase_20260916_221530.sql
```

---

# 💾 Create MySQL Backup

The following command creates the SQL dump:

```bash
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE_NAME
```

The resulting file contains the SQL required to restore the database.

Example:

```text
DummyDatabase_20260916_221530.sql
```

---

# ☁️ Upload Backup to S3

AWS credentials are configured:

```bash
export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=eu-central-1
```

The backup is then uploaded:

```bash
aws s3 cp $BACKUP_FILE_NAME s3://$S3_BUCKET_NAME/
```

After a successful upload:

```bash
aws s3 ls s3://devops-db-backup/
```

Example:

```text
2026-09-16 22:15:32   15432 DummyDatabase_20260916_221530.sql
```

---

# 🔄 Jenkins Pipeline

The Jenkins pipeline contains one main stage:

```groovy
stage('Backup Database') {
    steps {
        sh '''
            chmod +x database_dump.sh
            ./database_dump.sh $DB_USER $DB_PASSWORD $DB_NAME $S3_BUCKET_NAME $ACCESS_KEY_ID $SECRET_ACCESS_KEY
        '''
    }
}
```

The pipeline:

```text
Jenkins
   │
   ▼
Checkout Repository
   │
   ▼
Execute database_dump.sh
   │
   ▼
mysqldump
   │
   ▼
Create .sql file
   │
   ▼
AWS CLI
   │
   ▼
Upload to S3
```

---

# ▶️ Run the Project

### Step 1 — Clone the repository

```bash
git clone <YOUR-REPOSITORY-URL>
cd mysql-s3-backup
```

### Step 2 — Make the script executable

```bash
chmod +x database_dump.sh
```

### Step 3 — Test the script manually

```bash
./database_dump.sh \
prod \
password \
DummyDatabase \
devops-db-backup \
YOUR_ACCESS_KEY \
YOUR_SECRET_KEY
```

### Step 4 — Verify the backup

Check the local file:

```bash
ls -lh *.sql
```

Check S3:

```bash
aws s3 ls s3://devops-db-backup/
```

### Step 5 — Create Jenkins Pipeline

In Jenkins:

```text
New Item
   ↓
Pipeline
   ↓
Pipeline Definition
   ↓
Pipeline script
```

Paste the contents of `Jenkinsfile`.

Then click:

```text
Build Now
```

---

# 📊 Expected Jenkins Output

A successful build should produce output similar to:

```text
=============================
=== MYSQL DATABASE BACKUP ===
=============================

[+] Creating MySQL Dump...

[+] Setting AWS Credentials...

[+] Uploading to S3: devops-db-backup

upload: ./DummyDatabase_20260916_221530.sql
to s3://devops-db-backup/DummyDatabase_20260916_221530.sql

[✔] Backup Complete!
```

Jenkins should finish with:

```text
Finished: SUCCESS
```

---

# 🔒 Security Improvements for Production

The current example is intentionally simple, but there are several things that should be changed before using it in production.

### ❌ Avoid credentials in the Jenkinsfile

Don't do this:

```groovy
DB_PASSWORD = 'password'
ACCESS_KEY_ID = 'AKIAXXXXXXXX'
SECRET_ACCESS_KEY = 'XXXXXXXXXXXXXXX'
```

Instead, store secrets in **Jenkins Credentials**.

---

### ❌ Avoid passing passwords as command-line arguments

This:

```bash
./database_dump.sh $DB_USER $DB_PASSWORD ...
```

can expose sensitive values through process information or logs depending on how the command is executed.

A safer implementation can use environment variables or a protected MySQL configuration file.

---

### ✅ Use IAM Roles where possible

If Jenkins is running on AWS EC2, attach an IAM Role to the instance.

Then the AWS CLI can authenticate without storing:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

---

### ✅ Use Least-Privilege IAM

The Jenkins identity should only have the permissions it needs.

For example:

```text
s3:PutObject
s3:ListBucket
```

and only for the required bucket/prefix.

---

### ✅ Enable S3 Versioning

S3 versioning can help protect backups from accidental deletion or overwriting.

---

### ✅ Enable S3 Lifecycle Policies

Old backups can automatically transition to cheaper storage or be deleted after a defined retention period.

Example:

```text
0–30 days    → Standard
30–90 days   → Infrequent Access
90+ days     → Archive
```

---

# 🔁 Possible Production Workflow

A more production-oriented architecture could look like:

```text
             Jenkins
                │
                ▼
        Backup Pipeline
                │
                ▼
        MySQL Database
                │
                ▼
          mysqldump
                │
                ▼
       Compress with gzip
                │
                ▼
       ┌─────────────────┐
       │     AWS S3      │
       │                 │
       │ /mysql-backups/ │
       └────────┬────────┘
                │
        Lifecycle Policy
                │
                ▼
       Glacier / Archive
```

The backup can also be compressed:

```bash
mysqldump ... | gzip > ${DB_NAME}_${DATETIME}.sql.gz
```

Then upload:

```bash
aws s3 cp backup.sql.gz s3://devops-db-backup/
```

This reduces storage requirements and transfer size.

---

# 🕐 Automating Backups

Jenkins can run the pipeline automatically using a cron schedule.

For example:

```text
H 2 * * *
```

This runs approximately once per day around 2 AM.

Another option is:

```text
H */6 * * *
```

which runs approximately every 6 hours.

---

# ♻️ Database Restore

A backup is only useful if it can be restored.

Download a backup:

```bash
aws s3 cp \
s3://devops-db-backup/DummyDatabase_20260916_221530.sql \
.
```

Restore it:

```bash
mysql -u prod -p DummyDatabase < DummyDatabase_20260916_221530.sql
```

For a compressed backup:

```bash
gunzip < DummyDatabase_20260916_221530.sql.gz | \
mysql -u prod -p DummyDatabase
```

**Always test restoration periodically.**

---

# 🎯 What This Project Demonstrates

This project demonstrates practical DevOps skills including:

* Jenkins Pipeline
* CI/CD automation
* Bash scripting
* Linux administration
* MySQL database administration
* `mysqldump`
* AWS CLI
* Amazon S3
* Cloud backup automation
* IAM security concepts
* Backup retention
* Database restore procedures

---

# 🚀 Future Improvements

The project can be extended with:

* Jenkins Credentials
* AWS IAM Role authentication
* Automated scheduled backups
* GZIP compression
* S3 lifecycle policies
* S3 versioning
* Backup retention
* Slack/email notifications
* Backup integrity checks
* Restore testing
* Encryption using AWS KMS
* CloudWatch monitoring
* Terraform infrastructure provisioning

---

## 📌 Project Summary

**Jenkins → Bash → MySQL → mysqldump → AWS CLI → Amazon S3**

This project provides a simple foundation for learning how DevOps automation can be used to create and securely store database backups in AWS.
