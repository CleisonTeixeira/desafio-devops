Desafio DevOps – Terraform, Ansible e Jenkins

Este projeto provisiona e configura uma infraestrutura mínima em AWS utilizando **Terraform** para orquestração da infraestrutura, **Ansible** para configuração dos serviços (MySQL e Apache Kafka) e **Jenkins** para pipeline de CI/CD que automatiza todo o processo.

---

 Estrutura do Projeto

```
desafio-devops/
├─ README.md               Documentação do projeto
├─ .gitignore              Arquivos ignorados no Git
├─ Jenkinsfile             Pipeline declarativo para o Jenkins
├─ terraform/              Código de infraestrutura
│  ├─ backend.tf
│  ├─ providers.tf
│  ├─ variables.tf
│  ├─ vpc.tf
│  ├─ security_groups.tf
│  ├─ ec2.tf
│  ├─ outputs.tf
│  └─ files/
│     └─ cloud-init-common.sh
└─ ansible/                Playbooks e roles para configuração
   ├─ ansible.cfg
   ├─ generate_inventory.sh
   ├─ inventories/
   │  └─ hosts.ini
   ├─ playbooks/
   │  ├─ mysql.yml
   │  └─ kafka.yml
   └─ roles/
      ├─ mysql/
      │  ├─ tasks/main.yml
      │  ├─ handlers/main.yml
      │  ├─ templates/my.cnf.j2
      │  └─ vars/main.yml
      └─ kafka/
         ├─ tasks/main.yml
         ├─ handlers/main.yml
         ├─ templates/kafka.service.j2
         ├─ templates/zookeeper.service.j2
         └─ vars/main.yml
```

---

 Fluxo do Projeto

1. **Provisionamento de Infraestrutura**  
   - O Terraform cria:
     - VPC, Subnet, Internet Gateway e Route Table.  
     - Security Groups com regras para SSH, MySQL e Kafka/Zookeeper.  
     - Duas instâncias EC2 (Ubuntu 22.04):  
       - Uma para MySQL.  
       - Uma para Kafka e Zookeeper.  

2. **Configuração com Ansible**  
   - Após o `terraform apply`, é gerado o inventário (`ansible/inventories/hosts.ini`) com os IPs públicos das instâncias.  
   - Playbooks executam a configuração:  
     - `mysql.yml`: instala e configura MySQL.  
     - `kafka.yml`: instala e configura Kafka e Zookeeper como serviços systemd.  

3. **Pipeline com Jenkins**  
   - O `Jenkinsfile` orquestra o processo completo:  
     - `terraform init/plan/apply`  
     - Geração do inventário  
     - Execução dos playbooks do Ansible  
     - Testes para verificar se os serviços estão ativos  
     - (opcional) `terraform destroy`  

---

 Pré-requisitos

- Conta AWS com credenciais de administrador.  
- Chave SSH gerada previamente.  
- Terraform versão 1.6 ou superior.  
- Ansible versão 2.14 ou superior.  
- AWS CLI v2 configurado.  
- Jenkins instalado.  

---

 Execução Manual

 1. Provisionar com Terraform
```bash
cd terraform
terraform init
terraform validate
terraform plan -out=tf.plan
terraform apply -auto-approve tf.plan
```

 2. Gerar inventário para Ansible
```bash
cd ../ansible
./generate_inventory.sh
ansible -i inventories/hosts.ini all -m ping
```

 3. Executar playbooks
```bash
ansible-playbook -i inventories/hosts.ini playbooks/mysql.yml
ansible-playbook -i inventories/hosts.ini playbooks/kafka.yml
```

 4. Testar serviços
```bash
ansible -i inventories/hosts.ini mysql -m shell -a "systemctl is-active mysql"
ansible -i inventories/hosts.ini kafka -m shell -a "systemctl is-active kafka"
```

 5. Destruir ambiente
```bash
cd ../terraform
terraform destroy -auto-approve
```

---

 Execução via Jenkins

1. Configurar credenciais no Jenkins:
   - `aws-admin`: Access Key / Secret Key.  
   - `ssh-ansible`: Chave privada para acesso às instâncias.  

2. Criar um pipeline apontando para este repositório.  

3. Executar o job:
   - `DESTROY=false`: cria infraestrutura, configura e testa.  
   - `DESTROY=true`: destrói recursos provisionados.  

---

 Resultado Esperado

- Infraestrutura provisionada na AWS.  
- Instância MySQL acessível externamente na porta 3306.  
- Instância Kafka e Zookeeper acessível nas portas 9092 e 2181.  
- Pipeline Jenkins executando todas as etapas com sucesso.  