terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.33.0"
    }
  }
  backend "s3" {
    bucket         = "sonarqube-poc-tfstate-20240704233550"
    key            = "./terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "sonarqube-tfstate-lock-table-20240704233550"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}
