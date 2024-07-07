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

