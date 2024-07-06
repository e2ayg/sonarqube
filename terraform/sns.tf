resource "aws_sns_topic" "sonarqube-alerts" {
  name              = "SonarQubeAlerts"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "email-subscription" {
  topic_arn = aws_sns_topic.sonarqube-alerts.arn
  protocol  = "email"
  endpoint  = var.email
}
