pipeline {
    agent any

    stages {
        stage('Pull Latest Code') {
            steps {
                git branch: 'main', url: 'https://github.com/MadhawaRathnayake/Note-App.git'
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker build -t madhawarathnayake/note-backend:latest ./backend/NoteApp'
                sh 'docker build -t madhawarathnayake/note-frontend:latest ./frontend/note-app'
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '']) {
                    sh 'docker push madhawarathnayake/note-backend:latest'
                    sh 'docker push madhawarathnayake/note-frontend:latest'
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@your-ec2-ip "cd /path/to/docker-compose && docker-compose pull && docker-compose up -d --remove-orphans"'
                }
            }
        }
    }
}
