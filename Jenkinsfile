pipeline {
  agent any

  parameters {
    booleanParam(name: 'DESTROY', defaultValue: false, description: 'Destruir a infra ao final?')
  }

  environment {
    TF_IN_AUTOMATION = 'true'
    TF_INPUT = 'false'
    TF_VAR_project = 'desafio-devops'
    AWS_REGION = 'us-east-1'
    // Se usar credentials do Jenkins, mapeie via withCredentials nos steps.
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Terraform Init & Plan') {
      steps {
        dir('terraform') {
          sh '''
            terraform init -input=false
            terraform validate
            terraform plan -out=tf.plan
          '''
        }
      }
    }

    stage('Terraform Apply') {
      when { expression { return !params.DESTROY } }
      steps {
        dir('terraform') {
          sh 'terraform apply -auto-approve tf.plan'
        }
      }
    }

    stage('Gerar Inventário Ansible') {
      when { expression { return !params.DESTROY } }
      steps {
        dir('ansible') {
          sh './generate_inventory.sh'
          sh 'cat inventories/hosts.ini'
        }
      }
    }

    stage('Configuração Ansible') {
      when { expression { return !params.DESTROY } }
      steps {
        dir('ansible') {
          sh '''
            ansible --version
            ansible-playbook -i inventories/hosts.ini playbooks/mysql.yml
            ansible-playbook -i inventories/hosts.ini playbooks/kafka.yml
          '''
        }
      }
    }

    stage('Testes de Serviços') {
      when { expression { return !params.DESTROY } }
      steps {
        dir('ansible') {
          sh '''
            ansible -i inventories/hosts.ini mysql -m shell -a "systemctl is-active mysql"
            ansible -i inventories/hosts.ini kafka -m shell -a "systemctl is-active kafka"
          '''
        }
      }
    }

    stage('Terraform Destroy (opcional)') {
      when { expression { return params.DESTROY == true } }
      steps {
        dir('terraform') {
          sh 'terraform destroy -auto-approve'
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'ansible/inventories/hosts.ini', allowEmptyArchive: true
    }
  }
}
