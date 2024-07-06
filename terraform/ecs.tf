resource "aws_ecs_service" "sonarqube-service" {
  name            = "sonarqube-service"
  cluster         = aws_ecs_cluster.sonarqube-cluster.id
  task_definition = aws_ecs_task_definition.sonarqube.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.sonarqube-public-subnet-1.id, aws_subnet.sonarqube-public-subnet-2.id]
    security_groups = [aws_security_group.sonarqube-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube-tg.arn
    container_name   = "sonarqube"
    container_port   = 9000
  }

  depends_on = [
    aws_ecs_task_definition.sonarqube,
    aws_lb_target_group.sonarqube-tg
  ]

  tags = var.common_tags
}
