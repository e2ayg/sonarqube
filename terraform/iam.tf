resource "aws_iam_role" "ecs-task-execution-role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecs-task-execution-policy" {
  name        = "ecs_task_execution_policy"
  description = "Policy to allow ECS tasks to access Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          aws_secretsmanager_secret.sonarqube-db-credentials.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy-attach" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_kms_access" {
  name = "ecs_kms_access"
  role = aws_iam_role.ecs-task-execution-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          aws_kms_key.ebs.arn,
          aws_kms_key.efs.arn,
          aws_kms_key.rds.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecr_scan_role" {
  name = "ecr-scan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecr.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_scan_policy" {
  name        = "ecr-scan-policy"
  description = "Policy to allow ECR image scanning"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:StartImageScan",
          "ecr:DescribeImageScanFindings",
          "ecr:ListImages",
          "ecr:DescribeRepositories"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_scan_policy_attachment" {
  role       = aws_iam_role.ecr_scan_role.name
  policy_arn = aws_iam_policy.ecr_scan_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-xray" {
  role       = aws_iam_role.ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}