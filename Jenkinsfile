pipeline {
    agent any

    environment {
        DB_USER = 'prod'
        DB_PASSWORD = 'password'
        DB_NAME = 'DummyDatabase'
        S3_BUCKET_NAME = 'devops-db-backup'
        ACCESS_KEY_ID = 'AKIAXXXXXXXX'
        SECRET_ACCESS_KEY = 'XXXXXXXXXXXXXXX'
    }

    stages {
        stage('Backup Database') {
            steps {
                sh '''
                    chmod +x database_dump.sh
                    ./database_dump.sh $DB_USER $DB_PASSWORD $DB_NAME $S3_BUCKET_NAME $ACCESS_KEY_ID $SECRET_ACCESS_KEY
                '''
            }
        }
    }
}
