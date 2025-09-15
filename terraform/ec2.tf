data "aws_ami" "ubuntu2204" {
  owners      = ["099720109477"] # Canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project}-kp"
  public_key = var.public_key
}

locals {
  common_tags = {
    Project = var.project
  }
  user_data = file("${path.module}/files/cloud-init-common.sh")
}

resource "aws_instance" "mysql" {
  ami                         = data.aws_ami.ubuntu2204.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.common.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = merge(local.common_tags, {
    Role = "mysql"
    Name = "${var.project}-mysql"
  })
}

resource "aws_instance" "kafka" {
  ami                         = data.aws_ami.ubuntu2204.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.common.id]
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true
  user_data                   = local.user_data

  tags = merge(local.common_tags, {
    Role = "kafka"
    Name = "${var.project}-kafka"
  })
}
