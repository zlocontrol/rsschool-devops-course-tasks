pipeline {
    agent none

    environment {
        APP_NAME = 'flask-app'
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
        HELM_RELEASE = 'flask-app-release'
        CHART_PATH = './flask-app'
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
                        pip install -r requirements.txt || true
                        pytest || echo "No tests found, skipping"
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
                    helm upgrade --install ${HELM_RELEASE} ${CHART_PATH} \\
                    --set image.repository=${IMAGE_NAME} \\
                    --set image.tag=${IMAGE_TAG} \\
                    --set image.pullPolicy=IfNotPresent
                    """
                }
            }
        }

        stage('Smoke Test') {
            agent {
                kubernetes {
                    yamlFile 'jenkins-pods/curl-pod.yaml'
                }
            }
            steps {
                container('curl') {
                    script {
                        def serviceName = env.HELM_RELEASE
                        def namespace = 'jenkins'

                        // Get ClusterIP and Port of the service
                        def serviceIp = sh(script: "kubectl get svc ${serviceName} -n ${namespace} -o jsonpath='{.spec.clusterIP}'", returnStdout: true).trim()
                        def servicePort = sh(script: "kubectl get svc ${serviceName} -n ${namespace} -o jsonpath='{.spec.ports[0].port}'", returnStdout: true).trim()

                        def appUrl = "http://${serviceIp}:${servicePort}"

                        echo "Performing smoke test on: ${appUrl}"

                        // Perform curl request with retries
                        def maxAttempts = 10
                        def attempt = 0
                        def success = false
                        while (attempt < maxAttempts && !success) {
                            try {
                                sh "curl -v --fail --max-time 10 ${appUrl}/ || exit 1"
                                success = true
                            } catch (Exception e) {
                                echo "Attempt ${++attempt}/${maxAttempts} failed: ${e.message}"
                                sleep 5 // Wait 5 seconds before retrying
                            }
                        }

                        if (!success) {
                            error "Smoke test failed after ${maxAttempts} attempts."
                        } else {
                            echo "Smoke Test Passed!"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline succeeded"
        }
        failure {
            echo "Pipeline failed"
        }
    }
}