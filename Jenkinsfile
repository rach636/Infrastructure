pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_environment = 'prod'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 1, unit: 'HOURS')
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/rach636/Infrastructure.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform/environments/prod') {
                    sh 'terraform init -reconfigure -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform/environments/prod') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                sh '''
                docker run --rm -v $(pwd)/terraform:/terraform bridgecrew/checkov \
                    -d /terraform/environments/prod \
                    --framework terraform
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform/environments/prod') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform/environments/prod') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo 'Infrastructure deployment pipeline succeeded.'
        }
        failure {
            echo 'Infrastructure deployment pipeline failed.'
        }
    }
}
