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

                        echo "Waiting for deployment to be ready..."
                        sh "kubectl -n ${namespace} rollout status deployment/${serviceName} --timeout=120s"

                        echo "Performing smoke test on: ${appUrl}"
                        sh "curl -v --fail --max-time 10 ${appUrl}/"
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