pipeline {
  agent any
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
          archiveArtifacts artifacts: 'tests_coverage.txt', followSymlinks: false
        }
        failure {
          echo 'Tests: failing'
        }
      }
    }
    stage('Deploy') {
      steps {
        sh 'docker-compose up -d'
      }
      post {
        success {
          echo 'Deployed!'
        }
        failure {
          echo 'Deployment failed'
        }
      }
    }
  }
}
