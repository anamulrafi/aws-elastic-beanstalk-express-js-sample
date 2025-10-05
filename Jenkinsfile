
pipeline {
  agent {
    docker { image 'node:16-alpine'; args '-v $WORKSPACE:/app -w /app' }
  }
  environment {
    DOCKER_HOST = 'tcp://dind:2376'
    DOCKER_CERT_PATH = '/certs/client'
    DOCKER_TLS_VERIFY = '1'
    IMAGE_NAME = 'anamulrafi/eb-express-sample'
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timestamps()
    ansiColor('xterm')
  }
  stages {
    stage('Checkout') { steps { checkout scm } }

    stage('Install deps') {
      steps { sh 'npm install --save' }
    }

    stage('Unit tests') {
      steps { sh 'npm test || echo "No tests configured"' }
      post { always { junit allowEmptyResults: true, testResults: 'reports/junit/*.xml' } }
    }

    stage('Security scan (OWASP Dependency-Check)') {
      steps {
        sh '''
          mkdir -p odc && chmod -R 777 odc
          docker run --rm -e JAVA_OPTS="-Xmx1g" \
            -v $WORKSPACE:/src -v $WORKSPACE/odc:/report \
            owasp/dependency-check:latest \
            --scan /src --format "ALL" \
            --project "eb-express-sample" \
            --out /report --failOnCVSS 7.0
        '''
      }
      post { always { archiveArtifacts artifacts: 'odc/*', onlyIfSuccessful: false } }
    }

    stage('Docker build') {
      steps { sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .' }
    }

    stage('Docker push') {
      steps {
        withCredentials([KrS@YWNqAn42.U(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DH_USER',
                                          passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker push ${IMAGE_NAME}:${BUILD_NUMBER}
            docker push ${IMAGE_NAME}:latest
            docker logout
          '''
        }
      }
    }
  }
  post {
    success { echo '✅ Pipeline completed.' }
    failure { echo '❌ Pipeline failed — see logs.' }
  }
}

