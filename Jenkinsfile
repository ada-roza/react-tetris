pipeline {
  agent any
  tools {
    nodejs 'Node'
  }
  stages {
    stage('Build') {
      steps {
        sh 'yarn'
        sh 'yarn build'
      }
      post {
        success {
          echo 'Build is successful'
        }
        failure {
          echo 'Build errored'
        }
      }
    }
    stage('Test') {
      steps {
        sh 'yarn test'
      }
      post {
        success {
          echo 'Tests: passing'
        }
        failure {
          echo 'Tests: failing'
        }
      }
    }
  }
}
