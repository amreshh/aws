data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


resource "aws_ecr_repository" "container_repo" {
  name                 = "sandbox_ecr"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_registry_policy" "container_repo_policy" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "crossAccountPullOnly",
        Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs_role"
        },
        Action = [
          "ecr:ReplicateImage"
        ],
        Resource = [
          "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/sandbox_ecr"
        ]
      }
    ]
  })
}
