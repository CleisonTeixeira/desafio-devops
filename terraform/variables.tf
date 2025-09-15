variable "project" {
  type    = string
  default = "desafio-devops"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "public_key" {
  type        = string
  description = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJXhLPRED/cZMZLNOIGg2bOPhttt7YocN5Grhbirh/08 cleison-wsl"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "my_ip_cidr" {
  type        = string
  description = "177.198.159.60/32"
}
