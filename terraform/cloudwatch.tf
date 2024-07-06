resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name              = "/ecs/sonarqube"
  retention_in_days = 30

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name                = "SonarQubeHighCPUUtilization"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "Alarm when CPU utilization exceeds 80%"
  dimensions                = {
    ClusterName = aws_ecs_cluster.sonarqube-cluster.name
    ServiceName = aws_ecs_service.sonarqube-service.name
  }
  alarm_actions             = [aws_appautoscaling_policy.scale-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name                = "SonarQubeLowCPUUtilization"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  alarm_description         = "Alarm when CPU utilization is below 20%"
  dimensions                = {
    ClusterName = aws_ecs_cluster.sonarqube-cluster.name
    ServiceName = aws_ecs_service.sonarqube-service.name
  }
  alarm_actions             = [aws_appautoscaling_policy.scale-down.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm" {
  alarm_name          = "SonarQubeCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.sonarqube-cluster.name
    ServiceName = aws_ecs_service.sonarqube-service.name
  }

  alarm_actions = [
    aws_sns_topic.sonarqube-alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.sonarqube-alerts.arn
  ]

  tags = var.common_tags
}

# CloudWatch Alarm for Memory Utilization
resource "aws_cloudwatch_metric_alarm" "memory-alarm" {
  alarm_name          = "SonarQubeMemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.sonarqube-cluster.name
    ServiceName = aws_ecs_service.sonarqube-service.name
  }

  alarm_actions = [
    aws_sns_topic.sonarqube-alerts.arn
  ]

  ok_actions = [
    aws_sns_topic.sonarqube-alerts.arn
  ]

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "sonarqube-dashboard" {
  dashboard_name = "SonarQubeDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.sonarqube-cluster.name, "ServiceName",
              aws_ecs_service.sonarqube-service.name
            ]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-west-2",
          "title" : "ECS CPU Utilization"
        }
      },
      {
        "type" : "metric",
        "x" : 6,
        "y" : 0,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "metrics" : [
            [
              "AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.sonarqube-cluster.name, "ServiceName",
              aws_ecs_service.sonarqube-service.name
            ]
          ],
          "period" : 300,
          "stat" : "Average",
          "region" : "us-west-2",
          "title" : "ECS Memory Utilization"
        }
      }
    ]
  })
}