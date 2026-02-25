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
                echo 'Cloning infrastructure repo...'
                git branch: 'main', url: 'https://github.com/rach636/Infrastructure.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform/environments/prod') {
                    sh '''
                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Checkov Scan') {
            steps {
                echo 'Running Checkov on Terraform code'
                sh '''
                    docker run --rm -v $(pwd)/terraform:/terraform bridgecrew/checkov \
                        -d /terraform/environments/dev \
                        --framework terraform
                '''
            }
        }

        stage('Apply ECS Configuration') {
            steps {
                dir('terraform/environments/prod') {
                    sh '''
                        terraform apply -auto-approve -target=module.ecs
                    '''
                }
            }
        }

        stage('Apply RDS Configuration') {
            steps {
                dir('terraform/environments/prod') {
                    sh '''
                        terraform apply -auto-approve -target=module.rds
                    '''
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
