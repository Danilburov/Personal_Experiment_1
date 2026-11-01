pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
    ansiColor('xterm')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    INFRA_DIR = 'jenkins-infra-lab/infra'
  }

  stages {
    stage('Terraform init') {
      steps {
        sh 'terraform -chdir="$INFRA_DIR" init -input=false'
      }
    }

    stage('Plan destroy') {
      steps {
        sh 'terraform -chdir="$INFRA_DIR" plan -destroy -input=false -out=tfplan'
      }
    }

    stage('Approve') {
      steps {
        input message: 'Destroy everything in infra/? (the state bucket is not affected)', ok: 'Destroy'
      }
    }

    stage('Destroy') {
      steps {
        sh 'terraform -chdir="$INFRA_DIR" apply -input=false tfplan'
      }
    }
  }
}