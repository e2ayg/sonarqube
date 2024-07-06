resource "aws_ecr_repository" "sonarqube" {
  name = "sonarqube"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "docker-build-push" {
  triggers = {
    dockerfile_hash = filemd5("../docker/Dockerfile")
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.sonarqube.repository_url}
      docker build -t ${aws_ecr_repository.sonarqube.repository_url}:latest ${path.root}/docker
      docker push ${aws_ecr_repository.sonarqube.repository_url}:latest
    EOF
  }
}

resource "aws_ecs_cluster" "sonarqube-cluster" {
  name = "sonarqube-cluster"

  tags = var.common_tags
}

resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "sonarqube-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1536"
  memory                   = "3072"

  volume {
    name = "sonarqube-data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.sonarqube.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

  container_definitions = jsonencode([
    {
      name      = "sonarqube"
      image     = "${aws_ecr_repository.sonarqube.repository_url}:latest"
      cpu       = 1024
      memory    = 2048
      essential = true
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        }
      ]
      environment = [
        {
          name  = "SONARQUBE_JDBC_URL"
          value = "jdbc:postgresql://${aws_db_instance.sonarqube-db.endpoint}/sonarqube"
        }
      ]
      secrets = [
        {
          name      = "SONARQUBE_JDBC_USERNAME"
          valueFrom = "${aws_secretsmanager_secret_version.sonarqube-db-credentials-version.secret_string}:username"
        },
        {
          name      = "SONARQUBE_JDBC_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret_version.sonarqube-db-credentials-version.secret_string}:password"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/sonarqube"
          awslogs-region        = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "sonarqube-data"
          containerPath = "/opt/sonarqube/data"
          readOnly      = false
        },
        {
          sourceVolume  = "sonarqube-data"
          containerPath = "/opt/sonarqube/extensions"
          readOnly      = false
        },
        {
          sourceVolume  = "sonarqube-data"
          containerPath = "/opt/sonarqube/logs"
          readOnly      = false
        }
      ]
    },
    {
      name      = "xray-daemon"
      image     = "amazon/aws-xray-daemon"
      cpu       = 32
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 2000
          protocol      = "udp"
        }
      ]
      environment = [
        {
          name  = "AWS_REGION"
          value = var.region
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/xray-daemon"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs-xray"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-task-execution-role.arn

  depends_on = [
    aws_secretsmanager_secret.sonarqube-db-credentials
  ]

  tags = var.common_tags
}