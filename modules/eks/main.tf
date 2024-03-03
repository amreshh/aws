resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_policy_attachment.eks_worker_policy_attachment
  ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.small"]
  disk_size       = 20

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_policy_attachment.eks_worker_policy_attachment
  ]
}