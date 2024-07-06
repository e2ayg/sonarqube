resource "aws_db_instance" "sonarqube-db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.3"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.database-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.sonarqube-db-subnet-group.name
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds.arn

  skip_final_snapshot = true
}
