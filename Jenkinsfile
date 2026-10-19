pipeline {
    agent any

    environment {
        IMAGE_NAME = "danu8747/fullstack:${GIT_COMMIT}"
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "java-app-cluster"
        NAMESPACE = "danush"
    }

    tools {
        jdk 'java-17'
        maven 'maven'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/danush242211ay/Java-fullstack-CICD.git'

                sh '''
                git fetch origin devops
                git checkout origin/devops -- Dockerfile deployment.yaml
                '''

                sh 'ls -la'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        stage('Build & Tag Docker Image') {
            steps {
                script {
                    sh 'printenv'
                    sh "docker build -t danu8747/fullstack:${GIT_COMMIT} ."
                }
            }
        }
        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push danu8747/fullstack:${GIT_COMMIT}"
                }
            }
        }
        
        stage('Updating the Cluster') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                }
            }
        }
        
        stage('Deploy To Kubernetes') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'java-app-cluster', contextName: '', credentialsId: 'kube', namespace: 'microdegree', restrictKubeConfigAccess: false, serverUrl: 'https://252F42923B030F505004AF57FD5297A3.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
                    sh "kubectl apply -f deployment.yml -n ${NAMESPACE}"
                }
            }
        }

        stage('Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'java-app-cluster', contextName: '', credentialsId: 'kube', namespace: 'microdegree', restrictKubeConfigAccess: false, serverUrl: 'https://252F42923B030F505004AF57FD5297A3.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "kubectl get pods -n ${NAMESPACE}"
                    sh "kubectl get svc -n ${NAMESPACE}"
                }
            }
        }
    }
}
