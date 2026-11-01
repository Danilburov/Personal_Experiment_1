pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    timestamps()
    ansiColor('xterm')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    INFRA_DIR   = 'jenkins-infra-lab/infra'
    ANSIBLE_DIR = 'jenkins-infra-lab/ansible'
  }

  stages {
    stage('Terraform init') {
      steps {
        sh 'terraform -chdir="$INFRA_DIR" init -input=false'
      }
    }

    stage('Terraform plan') {
      steps {
        script {
          def rc = sh(script: 'terraform -chdir="$INFRA_DIR" plan -input=false -detailed-exitcode -out=tfplan',
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
        sh 'terraform -chdir="$INFRA_DIR" apply -input=false tfplan'
      }
    }

    stage('Install k3s (Ansible)') {
      steps {
        dir(env.ANSIBLE_DIR) {
          sh 'ansible-playbook site.yml'
        }
      }
    }

    stage('Verify cluster') {
      steps {
        dir(env.ANSIBLE_DIR) {
          sh 'ansible-playbook verify.yml'
        }
      }
    }
  }
}