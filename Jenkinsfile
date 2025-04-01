pipeline {
    agent any

    stages {
        stage('Pull Code from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/MadhawaRathnayake/Note-App.git'
            }
        }

        stage('Build Backend') {
            steps {
                sh 'docker build -t madhawarathnayake/note-backend:latest ./backend/NoteApp'
            }
        }

        stage('Push Backend') {
            steps {
                sh 'docker push madhawarathnayake/note-backend:latest'
            }
        }

        stage('Build Frontend') {
            steps {
                sh 'docker build -t madhawarathnayake/note-frontend:latest ./frontend/note-app'
            }
        }

        stage('Push Frontend') {
            steps {
                sh 'docker push madhawarathnayake/note-frontend:latest'
            }
        }

        stage('Deploy via Ansible') {
            steps {
                ansiblePlaybook(
                    inventory: 'inventory.ini',         // ????????????????
                    playbook: 'ansible-deploy.yml',
                    credentialsId: 'your-ssh-key-id'    // ????????????????
                )
            }
        }
    }
}
