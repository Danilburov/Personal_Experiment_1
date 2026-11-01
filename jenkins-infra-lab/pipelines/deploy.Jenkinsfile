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

    stage('Terraform plan') {
      steps {
        script {
          def rc = sh(script: 'terraform -chdir=infra plan -input=false -detailed-exitcode -out=tfplan',
                      returnStatus: true)
          if (rc == 1) { error('terraform plan failed') }
          env.TF_HAS_CHANGES = (rc == 2) ? 'true' : 'false'
          echo "Infrastructure changes: ${env.TF_HAS_CHANGES}"
        }
      }
    }

    stage('Approve') {
      when { environment name: 'TF_HAS_CHANGES', value: 'true' }
      steps {
        input message: 'Apply this plan to AWS?', ok: 'Apply'
      }
    }

    stage('Terraform apply') {
      when { environment name: 'TF_HAS_CHANGES', value: 'true' }
      steps {
        sh 'terraform -chdir=infra apply -input=false tfplan'
      }
    }

    stage('Install k3s (Ansible)') {
      steps {
        dir('ansible') {
          sh 'ansible-playbook site.yml'
        }
      }
    }

    stage('Verify cluster') {
      steps {
        dir('ansible') {
          sh 'ansible-playbook verify.yml'
        }
      }
    }
  }
}