
resource "aws_vpc" "sonarqube-vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "sonarqube-public-subnet-1" {
  vpc_id                  = aws_vpc.sonarqube-vpc.id
  cidr_block              = "10.1.0.0/20"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sonarqube-public-subnet-2" {
  vpc_id                  = aws_vpc.sonarqube-vpc.id
  cidr_block              = "10.1.16.0/20"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sonarqube-private-subnet-1" {
  vpc_id            = aws_vpc.sonarqube-vpc.id
  cidr_block        = "10.1.32.0/20"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "sonarqube-private-subnet-2" {
  vpc_id            = aws_vpc.sonarqube-vpc.id
  cidr_block        = "10.1.48.0/20"
  availability_zone = "us-west-2b"
}

resource "aws_internet_gateway" "sonarqube-igw" {
  vpc_id = aws_vpc.sonarqube-vpc.id
}

resource "aws_route_table" "sonarqube-route-table" {
  vpc_id = aws_vpc.sonarqube-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sonarqube-igw.id
  }
}

resource "aws_route_table_association" "sonarqube-public-route-assoc-1" {
  subnet_id      = aws_subnet.sonarqube-public-subnet-1.id
  route_table_id = aws_route_table.sonarqube-route-table.id
}

resource "aws_route_table_association" "sonarqube-public-route-assoc-2" {
  subnet_id      = aws_subnet.sonarqube-public-subnet-2.id
  route_table_id = aws_route_table.sonarqube-route-table.id
}

resource "aws_db_subnet_group" "sonarqube-db-subnet-group" {
  name       = "sonarqube-db-subnet-group"
  subnet_ids = [aws_subnet.sonarqube-private-subnet-1.id, aws_subnet.sonarqube-private-subnet-2.id]
}