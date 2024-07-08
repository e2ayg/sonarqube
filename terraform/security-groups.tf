resource "aws_security_group" "sonarqube-sg" {
  name        = "SonarQube Security Group"
  description = "This security group allows inbound traffic on port 9000 (TCP) from the Sonarqube subnets (10.1.32.0/20 and 10.1.48.0/20) for accessing the SonarQube server."
  vpc_id      = aws_vpc.sonarqube-vpc.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["10.1.32.0/20", "10.1.48.0/20"]
    description = "Allow inbound traffic on port 9000 (TCP) from SonarQube subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_security_group" "database-sg" {
  name        = "Database Security Group"
  description = "This security group allows inbound traffic on port 5432 (TCP) from the Sonarqube subnets (10.1.32.0/20 and 10.1.48.0/20) for accessing the RDS database."
  vpc_id      = aws_vpc.sonarqube-vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.1.32.0/20", "10.1.48.0/20"]
    description = "Allow inbound traffic on port 5432 (TCP) from SonarQube subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_security_group" "load-balancer-sg" {
  name        = "Load Balancer Security Group"
  description = "This security group allows inbound traffic on port 443 (TCP) from the allowed IP address to the Load Balancer."
  vpc_id      = aws_vpc.sonarqube-vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "Allow inbound HTTPS traffic on port 443 (TCP) from allowed IP address"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_security_group" "efs-sg" {
  name        = "EFS Security Group"
  description = "This security group allows inbound traffic on port 2049 (TCP) from the Sonarqube VPC for accessing the EFS file system."
  vpc_id      = aws_vpc.sonarqube-vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.sonarqube-vpc.cidr_block]
    description = "Allow inbound NFS traffic on port 2049 (TCP) from SonarQube VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_security_group_rule" "allow-xray" {
  type              = "ingress"
  from_port         = 2000
  to_port           = 2000
  protocol          = "udp"
  cidr_blocks       = ["10.1.32.0/20", "10.1.48.0/20"]
  security_group_id = aws_security_group.sonarqube-sg.id
  description       = "Allow inbound UDP traffic on port 2000 from SonarQube subnets for X-Ray"
}
