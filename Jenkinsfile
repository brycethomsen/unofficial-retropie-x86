pipeline {
  agent any
  stages {
    stage('') {
      steps {
        sh '''

pwd; docker run -it --privileged -v `pwd`:/retro -w="/retro" debian ./build.sh'''
      }
    }
  }
}