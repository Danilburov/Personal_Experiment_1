pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
    ansiColor('xterm')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
  }

  stages {
    stage('Terraform init') {
      steps {
        sh 'terraform -chdir=infra init -input=false'
      }
    }

    stage('Plan destroy') {
      steps {
        sh 'terraform -chdir=infra plan -destroy -input=false -out=tfplan'
      }
    }

    stage('Approve') {
      steps {
        input message: 'Destroy everything in infra/? (the state bucket is not affected)', ok: 'Destroy'
      }
    }

    stage('Destroy') {
      steps {
        sh 'terraform -chdir=infra apply -input=false tfplan'
      }
    }
  }
}