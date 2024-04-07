data "tls_certificate" "eks_cert" {
  url = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer
}

data "aws_subnet" "public_az_a" {
  vpc_id = var.vpc_id
  tags = {
    Name = "public-subnet-eu-central-1a"
  }
}

data "aws_subnet" "public_az_b" {
  vpc_id = var.vpc_id
  tags = {
    Name = "public-subnet-eu-central-1b"
  }
}

data "aws_subnet" "private_az_a" {
  vpc_id = var.vpc_id
  tags = {
    Name = "private-subnet-eu-central-1a"
  }
}

data "aws_subnet" "private_az_b" {
  vpc_id = var.vpc_id
  tags = {
    Name = "private-subnet-eu-central-1b"
  }
}
