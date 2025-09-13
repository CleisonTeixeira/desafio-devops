#!/usr/bin/env bash
# cloud-init mínimo: atualiza pacotes e habilita SSH keepalive
apt-get update -y
apt-get upgrade -y
echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 5" >> /etc/ssh/sshd_config
systemctl restart ssh || systemctl restart sshd || true
