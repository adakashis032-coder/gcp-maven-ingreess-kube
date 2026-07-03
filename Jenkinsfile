pipeline {
    agent any

    tools {
        maven 'Maven-3.8.1'
        jdk 'JDK-11'
    }

    environment {
        DOCKER_IMAGE = "your-dockerhub-user/gcp-maven-ingress-kube:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/adakashis032-coder/gcp-maven-ingress-kube.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh "docker build -t $DOCKER_IMAGE ."
                    sh "docker login -u $USER -p $PASS"
                    sh "docker push $DOCKER_IMAGE"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh "kubectl --kubeconfig=$KUBECONFIG set image deployment/gcp-maven-ingress-kube gcp-maven-ingress-kube=$DOCKER_IMAGE --record"
                    sh "kubectl --kubeconfig=$KUBECONFIG rollout status deployment/gcp-maven-ingress-kube --timeout=60s"
                }
            }
        }

        stage('Monitor Pod Health') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh "kubectl --kubeconfig=$KUBECONFIG get pods -l app=gcp-maven-ingress-kube"
                    sh "kubectl --kubeconfig=$KUBECONFIG describe pods -l app=gcp-maven-ingress-kube"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build, push, and deploy succeeded!'
        }
        failure {
            echo '❌ Deployment failed. Rolling back...'
            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                sh "kubectl --kubeconfig=$KUBECONFIG rollout undo deployment/gcp-maven-ingress-kube"
            }
        }
    }
}
