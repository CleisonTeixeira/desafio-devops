output "mysql_public_ip" { value = aws_instance.mysql.public_ip }
output "kafka_public_ip" { value = aws_instance.kafka.public_ip }

output "inventory_json" {
  value = {
    mysql = aws_instance.mysql.public_ip
    kafka = aws_instance.kafka.public_ip
  }
}
