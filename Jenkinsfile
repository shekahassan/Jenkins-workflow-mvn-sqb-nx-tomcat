pipeline {

    agent any

    tools {

        jdk 'JDK17'

        maven 'Maven-3.9'

    }

    environment {

        SONARQUBE = 'SonarQube'

        TOMCAT_CREDENTIALS = 'tomcat-creds'

    }

    stages {

        stage('Checkout Source') {

            steps {

                checkout scm

            }

        }

        stage('Build') {

            steps {

                sh 'mvn clean compile'

            }

        }

        stage('Run Unit Tests') {

            steps {

                sh 'mvn test'

            }

            post {

                always {

                    junit 'target/surefire-reports/*.xml'

                }

            }

        }

        stage('Package Application') {

            steps {

                sh 'mvn package'

            }

        }

        stage('SonarQube Analysis') {

            steps {

                withSonarQubeEnv("${SONARQUBE}") {

                    sh 'mvn sonar:sonar'

                }

            }

        }

        stage('Quality Gate') {

            steps {

                timeout(time: 10, unit: 'MINUTES') {

                    waitForQualityGate abortPipeline: true

                }

            }

        }

        stage('Publish Artifact') {

            steps {

                sh 'mvn deploy'

            }

        }

        stage('Deploy to Tomcat') {

            steps {

                deploy adapters: [

                    tomcat9(

                        credentialsId: "${TOMCAT_CREDENTIALS}",

                        path: '',

                        url: 'http://<TOMCAT-SERVER>:8080'

                    )

                ],

                contextPath: 'employee-app',

                war: 'target/*.war'

            }

        }

    }

    post {

        success {

            echo 'Application deployed successfully.'

        }

        failure {

            echo 'Pipeline failed.'

        }

        always {

            archiveArtifacts artifacts: 'target/*.war', fingerprint: true

            cleanWs()

        }

    }

}
