#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
TMP_JSON="$(mktemp)"
terraform -chdir=../terraform output -json inventory_json > "$TMP_JSON"

MYSQL_IP=$(jq -r '.mysql.value // .mysql' "$TMP_JSON" 2>/dev/null || jq -r '.mysql' "$TMP_JSON")
KAFKA_IP=$(jq -r '.kafka.value // .kafka' "$TMP_JSON" 2>/dev/null || jq -r '.kafka' "$TMP_JSON")

mkdir -p inventories
cat > inventories/hosts.ini <<EOF
[mysql]
${MYSQL_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519

[kafka]
${KAFKA_IP} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519
EOF

echo "Inventário escrito em inventories/hosts.ini"
