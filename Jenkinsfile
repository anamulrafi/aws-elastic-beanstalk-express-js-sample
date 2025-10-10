// Jenkinsfile — Task 1 (CI/CD Automation)
pipeline {
  agent {
    // Use Node 16 as the build agent
    docker {
      image 'node:16-alpine'
      // Run as root & mount host Docker socket so we can docker build/push
      args '--user root -v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  environment {
    // Docker Hub settings
    REGISTRY           = ''                    // empty for Docker Hub
    REGISTRY_NAMESPACE = 'anamulrafi'          // your Docker Hub username
    APP_NAME           = '21995048_project2_pipeline' // your repo name
    IMAGE_TAG          = "${env.BUILD_NUMBER}" // each build gets its own tag
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
          # Install docker CLI inside the Node 16 container
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
        // required: use npm install --save
        sh 'npm install --save'
      }
    }

    stage('Run unit tests') {
      steps {
        sh 'npm test'
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
          echo "✅ Image pushed successfully: $IMAGE"
        '''
      }
    }
  }

  post {
    always { cleanWs() }
  }
}
