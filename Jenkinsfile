// Jenkinsfile — CI/CD + Security (Snyk) + Docker push
pipeline {
  agent {
    // Node 16 as build agent
    docker {
      image 'node:16-alpine'
      // allow docker build/push from inside the agent
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    // Docker Hub (REGISTRY empty means docker.io)
    REGISTRY           = ''
    REGISTRY_NAMESPACE = 'anamulrafi'
    APP_NAME           = '21995048_project2_pipeline'
    IMAGE_TAG          = "${env.BUILD_NUMBER}"
    CI                 = 'true'
  }

  options {
    timestamps()
    ansiColor('xterm')
  }

  stages {
    stage('Prepare Docker CLI') {
      steps {
        sh '''
          set -eux
          if [ -f /etc/alpine-release ]; then
            apk add --no-cache docker-cli git
          else
            apt-get update && apt-get install -y docker.io git && rm -rf /var/lib/apt/lists/*
          fi
          docker version || true
        '''
      }
    }

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install dependencies') {
      steps {
        // (Requirement) use npm install --save
        sh 'npm install --save'
      }
    }

    stage('Unit tests') {
      steps {
        sh 'npm test'
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '**/junit*.xml,**/test-results/*.xml'
        }
      }
    }

    stage('Security Scan (Snyk)') {
      // pipeline fails if High/Critical issues exist
      environment { SNYK_TOKEN = credentials('snyk_token') }
      steps {
        sh '''
          set -eux
          npm i -g snyk
          snyk auth "$SNYK_TOKEN"
          # Fail build if severity >= high (covers High & Critical)
          snyk test --severity-threshold=high --all-projects
        '''
      }
    }

    stage('Build Docker image') {
      steps {
        sh '''
          set -eux
          IMAGE="${REGISTRY:+$REGISTRY/}${REGISTRY_NAMESPACE}/${APP_NAME}:${IMAGE_TAG}"
          echo "$IMAGE" > .image_name
          docker build -t "$IMAGE" .
        '''
      }
    }

    stage('Push Docker image') {
      environment { REGISTRY_CREDS = credentials('registry_credentials') }
      steps {
        sh '''
          set -eux
          IMAGE="$(cat .image_name)"
          echo "$REGISTRY_CREDS_PSW" | docker login -u "$REGISTRY_CREDS_USR" --password-stdin
          docker push "$IMAGE"
          echo "✅ Pushed $IMAGE"
        '''
      }
    }
  }

  post {
    always { cleanWs() }
  }
}
