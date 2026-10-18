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
                git checkout origin/devops -- Dockerfile deployment.yml
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

        stage('Docker Image Scan') {
            steps {
                script {
                    sh "trivy image --format table -o trivy-image-report.html danu8747/fullstack:${GIT_COMMIT}"
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
                withKubeConfig(caCertificate: '', clusterName: 'java-app-cluster', contextName: '', credentialsId: 'kube', namespace: 'microdegree', restrictKubeConfigAccess: false, serverUrl: 'https://5DC0CED9029D05084DE963A8AD9BE68A.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "sed -i 's|replace|${IMAGE_NAME}|g' deployment.yml"
                    sh "kubectl apply -f deployment.yml -n ${NAMESPACE}"
                }
            }
        }

        stage('Verify the Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'java-app-cluster', contextName: '', credentialsId: 'kube', namespace: 'microdegree', restrictKubeConfigAccess: false, serverUrl: 'https://5DC0CED9029D05084DE963A8AD9BE68A.gr7.ap-south-1.eks.amazonaws.com') {
                    sh "kubectl get pods -n ${NAMESPACE}"
                    sh "kubectl get svc -n ${NAMESPACE}"
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'danush8747@gmail.com',
                    from: 'danush8747@gmail.com',
                    replyTo: 'danush8747@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}
