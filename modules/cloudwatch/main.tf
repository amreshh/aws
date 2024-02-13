resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/sandbox"
  retention_in_days = 1
}
