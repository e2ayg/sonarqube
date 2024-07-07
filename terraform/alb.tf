resource "aws_lb" "sonarqube-lb" {
  name                                        = "sonarqube-lb"
  internal                                    = false
  load_balancer_type                          = "application"
  security_groups                             = [aws_security_group.lb-sg.id]
  enable_tls_version_and_cipher_suite_headers = true
  subnets                                     = [aws_subnet.sonarqube-public-subnet-1.id, aws_subnet.sonarqube-public-subnet-2.id]

  access_logs {
    bucket  = aws_s3_bucket.alb-access-logs.id
    prefix  = "sonarqube-lb"
    enabled = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.sonarqube-lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube-tg.arn
  }

}

resource "aws_lb_target_group" "sonarqube-tg" {
  name     = "sonarqube-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_vpc.sonarqube-vpc.id
}

resource "aws_appautoscaling_target" "sonarqube" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.sonarqube-cluster.name}/${aws_ecs_service.sonarqube-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale-up" {
  name               = "scale-up"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sonarqube.resource_id
  scalable_dimension = aws_appautoscaling_target.sonarqube.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sonarqube.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_appautoscaling_policy" "scale-down" {
  name               = "scale-down"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sonarqube.resource_id
  scalable_dimension = aws_appautoscaling_target.sonarqube.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sonarqube.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 20.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

resource "aws_s3_bucket" "alb-access-logs" {
  bucket = "sonarqube-alb-access-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "sonarqube-alb-access-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "alb_access_logs" {
  bucket = aws_s3_bucket.alb-access-logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}