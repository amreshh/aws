data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Sandbox VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "VPC Internet Gateway"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "10.0.0.0/16"
  }

  tags = {
    Name = "Default Route Table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_default_route_table.default_route_table.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs_security_group"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  egress {
    description      = "Allow egress tls traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Allow ingress tls traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "TLS Traffic"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_default_route_table.default_route_table.id]
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  auto_accept       = true

  tags = {
    Name = "S3"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  auto_accept         = true
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
  security_group_ids  = [aws_security_group.ecs_security_group.id]

  tags = {
    Name = "ECR API"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  auto_accept         = true
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
  security_group_ids  = [aws_security_group.ecs_security_group.id]

  tags = {
    Name = "ECR Docker Registry"
  }
}

resource "aws_vpc_endpoint" "ecr_cloudwatch" {
  vpc_id              = aws_vpc.main.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  auto_accept         = true
  private_dns_enabled = true
  subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
  security_group_ids  = [aws_security_group.ecs_security_group.id]

  tags = {
    Name = "ECR Cloudwatch Logs"
  }
}
