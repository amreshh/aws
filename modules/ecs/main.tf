resource "aws_ecs_cluster" "ecs_cluster" {
  name = "sandbox-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = var.cloud_watch_log_group_name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_provider" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base              = 1
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "s3_test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.task_role_arn

  container_definitions = jsonencode([
    {
      name  = "s3_test"
      image = "${var.ecr_url}:fedora_aws_cli"
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.cloud_watch_log_group_name
          "awslogs-region"        = "eu-central-1"
          "awslogs-stream-prefix" = "s3_test"
        }
      }
    }
  ])
}
