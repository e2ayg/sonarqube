resource "aws_kms_key" "rds" {
  description = "KMS key for encrypting RDS cluster"
}

resource "aws_kms_key" "ebs" {
  description = "KMS key for encrypting EBS volumes"
}

resource "aws_kms_key" "s3" {
  description = "KMS key for encrypting S3 buckets"
}

resource "aws_kms_key" "efs" {
  description = "KMS key for encrypting EFS volumes"
}