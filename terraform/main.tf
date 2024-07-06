terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.33.0"
    }
  }
  backend "s3" {
    bucket         = "<S3 bucket name>"
    key            = "./terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "<DynamoDB table name>"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}
