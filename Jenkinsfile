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
  }

  stages {

    stage('Checkout') {
      steps {
        // usa o SCM configurado no job (já autenticando com github-pat se estiver no job)
        checkout scm
      }
    }

    stage('Preparar tfvars (credenciais)') {
      steps {
        withCredentials([
          string(credentialsId: 'tf-public-key', variable: 'TF_PUBLIC_KEY'),
          string(credentialsId: 'tf-my-ip-cidr', variable: 'TF_MY_IP_CIDR')
        ]) {
          sh '''
            set -e
            cat > terraform/terraform.auto.tfvars <<EOF
public_key = "${TF_PUBLIC_KEY}"
my_ip_cidr = "${TF_MY_IP_CIDR}"
EOF
            echo "[INFO] Gerado terraform/terraform.auto.tfvars"
          '''
        }
      }
    }

    stage('Terraform Init & Plan') {
      steps {
        dir('terraform') {
          sh '''
            set -e
            terraform init -input=false -reconfigure
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
          sh '''
            set -e
            ./generate_inventory.sh
            echo "=== inventories/hosts.ini ==="
            cat inventories/hosts.ini
          '''
        }
      }
    }

    stage('Configuração Ansible') {
      when { expression { return !params.DESTROY } }
      steps {
        dir('ansible') {
          sh '''
            set -e
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
            set -e
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
      archiveArtifacts artifacts: 'terraform/tf.plan,ansible/inventories/hosts.ini', allowEmptyArchive: true
    }
  }
}
