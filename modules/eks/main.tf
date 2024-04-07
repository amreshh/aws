resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = [
      data.aws_subnet.public_az_a.id,
      data.aws_subnet.public_az_b.id,
      data.aws_subnet.private_az_a.id,
      data.aws_subnet.private_az_b.id,
    ]
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
    aws_iam_policy_attachment.eks_cluster_policy_attachment
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids = [
    data.aws_subnet.private_az_a.id,
    data.aws_subnet.private_az_b.id,
  ]
  capacity_type  = "SPOT" # ON_DEMAND
  instance_types = ["t2.medium"]
  disk_size      = 20
  version        = "1.29"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  labels = {
    "node" = "kubenode02"
  }

  depends_on = [
    aws_iam_policy_attachment.eks_node_group_attachment
  ]
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cert.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity.0.oidc.0.issuer

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.eks_node_group
  ]
}
