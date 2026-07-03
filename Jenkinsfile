pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-user/gcp-maven-ingress-kube:${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/adakashis032-coder/gcp-maven-ingress-kube',
                    credentialsId: '085c5197-0276-4de3-b806-90c1f60d8935'
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
