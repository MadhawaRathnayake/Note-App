pipeline {
    agent any

    environment{
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
    }

    tools {
        maven 'mvn-3.9.8'
        nodejs 'node-22.12.0'
    }

    stages {
        stage('Pull Code from GitHub') {
            steps {
                git branch: 'main', url: 'https://github.com/MadhawaRathnayake/Note-App.git', credentialsId: 'Github-Credentials'
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend/NoteApp') {  
                    script {
                        withCredentials([usernamePassword(credentialsId: 'notekeep-prod-database-credentials', usernameVariable: 'MONGODB_USERNAME', passwordVariable: 'MONGODB_PASSWORD')]) {
                            sh '''#!/bin/bash
                            echo "Building backend with Mongodb database"
                            export MONGODB_USERNAME=$MONGODB_USERNAME
                            export MONGODB_PASSWORD=$MONGODB_PASSWORD
                            mvn clean package
                            '''
                        }
                    }
                }
            }
        }

        stage('Backend Tests') {
            steps {
                dir('backend/NoteApp') {
                    sh 'mvn test'
                }
            }
        }
        stage('Build Frontend') {
            steps {
                dir('frontend/note-app') {  
                    echo "Building frontend"
                    sh 'npm install --save-dev @babel/plugin-proposal-private-property-in-object'
                    sh 'npm install react-select' 
                    sh 'npm install'
                    sh 'CI=false npm run build'
                }
            }
        }

        stage('Build Backend image') {
            steps {
                sh 'docker build -t madhawarathnayake/note-backend:latest ./backend/NoteApp'
            }
        }

        stage('Build Frontend image') {
            steps {
                sh 'docker build -t madhawarathnayake/note-frontend:latest ./frontend/note-app'
            }
        }

        stage('Push Backend image') {
            steps {
                dir('backend/NoteApp') {
                    script{
                        withCredentials([usernamePassword(credentialsId: 'Docker-Credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh 'docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"'
                            sh 'docker push madhawarathnayake/note-backend:latest'
                        }
                    }
                }
            }
        }

        stage('Push Frontend image') {
            steps {
                dir('frontend/note-app') {
                    script{
                        withCredentials([usernamePassword(credentialsId: 'Docker-Credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh 'docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"'
                            sh 'docker push madhawarathnayake/note-frontend:latest'
                        }
                    }
                }
            }
        }   

        stage('Deploy via Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible-deploy.yml',
                    inventory: 'inventory.ini',
                    become: true,
                    becomeUser: 'root'
                )
            }
        }

    }

    
    post {
        success {
            echo 'Pipeline executed successfully!'
     }
     failure {
         echo 'Pipeline execution failed!'
     }
    }

}
