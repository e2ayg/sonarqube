resource "aws_secretsmanager_secret" "sonarqube-db-credentials" {
  name = "sonarqube/db-credentials"
}

resource "aws_secretsmanager_secret_version" "sonarqube-db-credentials-version" {
  secret_id = aws_secretsmanager_secret.sonarqube-db-credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}
