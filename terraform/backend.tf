terraform {
  backend "s3" {
    bucket         = "s3-tfstate-cleison"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
