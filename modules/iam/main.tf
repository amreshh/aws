resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs_task_policy"
  description = "ECS Task Execution Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ECSExecutionPolicy",
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name        = "ecs_role"
  description = "ECS Execution Role"
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

resource "aws_iam_policy_attachment" "ecs_policy_attachment" {
  name       = "ecs_policy_attachment"
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  roles      = [aws_iam_role.ecs_execution_role.name]
}
