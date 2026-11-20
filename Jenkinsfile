pipeline {
    agent any

    // Tools installed inside our custom Jenkins image (see jenkins/Dockerfile).
    // If you use your own Jenkins, either install node/docker/terraform on it
    // or configure the NodeJS plugin and add:  tools { nodejs 'node20' }

    environment {
        APP_NAME   = 'cicd-demo-app'
        IMAGE_NAME = 'cicd-demo-app'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        HOST_PORT  = '3000'
        // Jenkins runs in a container; the app container is published on the Docker host.
        APP_URL    = "http://host.docker.internal:3000"
    }

    // Automatic source-code integration: Jenkins checks Git every ~2 minutes
    // and starts a build when it sees a new commit.
    triggers {
        pollSCM('H/2 * * * *')
    }

    options {
        timestamps()
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        stage('Checkout') {
            steps {
                // Pulls the code from the Git repo configured in the Jenkins job
                checkout scm
                sh 'git log -1 --pretty=format:"Commit: %h - %s (%an)"'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('app') {
                    sh 'node --version && npm --version'
                    sh 'npm install'
                }
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh 'npm test'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'app/coverage/**', allowEmptyArchive: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                }
                sh "docker images ${IMAGE_NAME}"
            }
        }

        stage('Terraform Init & Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform version'
                    sh 'terraform init -input=false'
                    sh 'terraform fmt -recursive'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh """
                        terraform plan -input=false \
                          -var="image_tag=${IMAGE_TAG}" \
                          -var="host_port=${HOST_PORT}" \
                          -out=tfplan
                    """
                }
            }
        }

        stage('Deploy (Terraform Apply)') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                // Give the container a moment, then check the health endpoint
                sh '''
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                      if curl -fs ${APP_URL}/health; then
                        echo ""
                        echo "Application is healthy"
                        exit 0
                      fi
                      echo "Waiting for app... ($i)"
                      sleep 3
                    done
                    echo "Smoke test FAILED"
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "SUCCESS: ${APP_NAME}:${IMAGE_TAG} deployed -> http://localhost:${HOST_PORT}"
        }
        failure {
            echo 'FAILURE: check the stage logs above'
        }
        always {
            echo "Build #${env.BUILD_NUMBER} finished with status: ${currentBuild.currentResult}"
        }
    }
}
