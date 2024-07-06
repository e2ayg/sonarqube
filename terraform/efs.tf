resource "aws_efs_file_system" "sonarqube" {
  encrypted  = true
  kms_key_id = aws_kms_key.efs.arn

  tags = var.common_tags
}

resource "aws_efs_mount_target" "sonarqube-public-1" {
  file_system_id  = aws_efs_file_system.sonarqube.id
  subnet_id       = aws_subnet.sonarqube-public-subnet-1.id
  security_groups = [aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "sonarqube-public-2" {
  file_system_id  = aws_efs_file_system.sonarqube.id
  subnet_id       = aws_subnet.sonarqube-public-subnet-2.id
  security_groups = [aws_security_group.efs-sg.id]
}
