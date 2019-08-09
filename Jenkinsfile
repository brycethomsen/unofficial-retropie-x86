pipeline {
  agent any
  stages {
    stage('error') {
      steps {
        sh '''

pwd; docker run --rm  --privileged -v `pwd`:/retro -w="/retro" debian ls'''
      }
    }
  }
}