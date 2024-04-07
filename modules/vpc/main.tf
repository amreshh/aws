data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "sandbox-vpc"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name                                = "public-subnet-${each.key}"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/eks_cluster" = "owned"

  }
}

resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name                                = "private-subnet-${each.key}"
    "kubernetes.io/role/internal-elb"   = "1"
    "kubernetes.io/cluster/eks_cluster" = "owned"

  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-internet-gateway"
  }
}

resource "aws_nat_gateway" "public_nat_gateway" {
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public_subnets["eu-central-1a"].id

  tags = {
    Name = "public-nat-gateway-eu-central-1a"
  }
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route = []

  tags = {
    Name = "default-route-table"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  for_each = var.private_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public_nat_gateway.id
  }

  tags = {
    Name = "private-route-table-${each.key}"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

# resource "aws_default_security_group" "default" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = -1
#     self      = true
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "Allow All Traffic"
#   }
# }

# resource "aws_security_group" "ecs_security_group" {
#   name = "ecs_security_group"
#   description = "Security group for ECS tasks"
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "ECS Security Group"
#   }
# }

# resource "aws_security_group" "vpc_endpoint_security_group" {
#   name = "vpc_endpoint_security_group"
#   description = "Security group for VPC endpoints"
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "VPC Endpoint Security Group"
#   }
# }

# resource "aws_vpc_security_group_egress_rule" "ecs_security_group_egress" {
#   security_group_id = aws_security_group.ecs_security_group.id
#   # cidr_ipv4 = "10.0.0.0/16"
#   cidr_ipv4 = "0.0.0.0/0"
#   ip_protocol = "tcp"
#   from_port = 443
#   to_port = 443

#   tags = {
#     Name = "Private Subnet Egress"
#   }
# }

# resource "aws_vpc_security_group_ingress_rule" "vpc_endpoint_security_group_ingress" {
#   security_group_id = aws_security_group.vpc_endpoint_security_group.id
#   cidr_ipv4 = "10.0.0.0/16"
#   ip_protocol = "tcp"
#   from_port = 443
#   to_port = 443

#   tags = {
#     Name = "Private Subnet TLS Ingress"
#   }
# }

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.main.id
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = [aws_default_route_table.default_route_table.id]
#   service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
#   auto_accept       = true

#   tags = {
#     Name = "S3"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.main.id
#   vpc_endpoint_type   = "Interface"
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
#   auto_accept         = true
#   private_dns_enabled = true
#   subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
#   security_group_ids  = [aws_security_group.vpc_endpoint_security_group.id]

#   tags = {
#     Name = "ECR API"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.main.id
#   vpc_endpoint_type   = "Interface"
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
#   auto_accept         = true
#   private_dns_enabled = true
#   subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
#   security_group_ids  = [aws_security_group.vpc_endpoint_security_group.id]

#   tags = {
#     Name = "ECR Docker Registry"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_cloudwatch" {
#   vpc_id              = aws_vpc.main.id
#   vpc_endpoint_type   = "Interface"
#   service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
#   auto_accept         = true
#   private_dns_enabled = true
#   subnet_ids          = [for subnet in aws_subnet.private_subnets : subnet.id]
#   security_group_ids  = [aws_security_group.vpc_endpoint_security_group.id]

#   tags = {
#     Name = "ECR Cloudwatch Logs"
#   }
# }
