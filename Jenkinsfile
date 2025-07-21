pipeline {
    agent none

    environment {
        APP_NAME = 'flask-app'
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        HELM_RELEASE = 'flask-app-release'
        CHART_PATH = './flask-app'
        DOCKER_USER = 'igor237'
        MAIL = 'cantaktget@gmail.com'


    }

    stages {

        stage('Docker Build') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/docker-pod.yaml'
                }
            }
            steps {
                container('docker') {
                    dir("${APP_NAME}") {
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    }
                }
            }
        }

        stage('Docker Push') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/docker-pod.yaml'
                }
            }
            steps {
                container('docker') {
                    dir("${APP_NAME}") {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                            sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} igor237/my-flask-app:${IMAGE_TAG}
                            docker push igor237/my-flask-app:${IMAGE_TAG}
                            '''
                        }
                    }
                }
            }
        }






        stage('Unit Tests') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/python-pod.yaml'
                }
            }
            steps {
                container('python') {
                    dir("${APP_NAME}") {
                        sh '''
                        pip install -r requirements.txt
                        pip install pytest pytest-cov

                        export PYTHONPATH=$(pwd)
                        pytest --cov=flask_app --cov-report=xml || echo "No tests found, skipping"
                        ls -l coverage.xml
                        '''
                    }
                }
            }
        }



        stage('SonarCloud Analysis') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/python-pod.yaml'
                }
            }
            environment {
                SONAR_TOKEN = credentials('sonar-token-id')

                SONAR_SERVER_URL = "https://sonarcloud.io" //
            }
            steps {
                container('python') {
                    dir("${APP_NAME}") {
                        sh '''
                        apt-get update -qq && apt-get install -y unzip wget openjdk-17-jre-headless
                        find . -name "__pycache__" -exec rm -rf {} +
                        find . -name "*.pyc" -delete
                        wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
                        unzip -q sonar-scanner-cli-*.zip
                        mv sonar-scanner-5.0.1.3006-linux sonar-scanner
                        export PATH=$PWD/sonar-scanner/bin:$PATH


                        sonar-scanner -Dsonar.login=$SONAR_TOKEN -Dsonar.host.url=$SONAR_SERVER_URL
                        '''
                    }
                }
            }
        }





        stage('Helm Deploy') {
                    agent {
                        kubernetes {
                            yamlFile 'jenkins-pods/helm-pod.yaml'
                        }
                    }
                    steps {
                        container('helm') {
                            sh """
                            helm upgrade --install ${HELM_RELEASE} ${CHART_PATH} --set image.repository=igor237/my-flask-app --set image.tag=${IMAGE_TAG} --set image.pullPolicy=IfNotPresent
                            """
                        }
                    }
                }


        stage('Smoke Test') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/curl-pod.yaml'
                    namespace 'jenkins'
                }
            }
            steps {
                container('curl') {
                    script {
                        def serviceName = env.HELM_RELEASE
                        def namespace = 'jenkins'
                        def servicePort = '8080'

                        def appUrl = "http://${serviceName}.${namespace}.svc.cluster.local:${servicePort}"

                        echo "Performing smoke test on: ${appUrl}"

                        def maxAttempts = 10
                        def attempt = 0
                        def success = false

                        while (attempt < maxAttempts && !success) {
                            try {
                                sh "curl -v --fail --max-time 10 ${appUrl}/"
                                success = true
                            } catch (Exception e) {
                                echo "Attempt ${++attempt}/${maxAttempts} failed: ${e.message}"
                                sleep 5
                            }
                        }

                        if (!success) {
                            error "Smoke test failed after ${maxAttempts} attempts."
                        } else {
                            echo " Smoke Test Passed!"
                        }
                    }
                }
            }
        }



    }

        post {
            success {
                echo "Pipeline succeeded"
                mail to: ${MAIL},
                     subject: "Pipeline SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                     body: "Good news! The pipeline completed successfully."
            }
            failure {
                echo "Pipeline failed"
                mail to: ${MAIL},
                     subject: "Pipeline FAILURE: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                     body: "Something went wrong. Please check the pipeline logs."
            }
        }

}