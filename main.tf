module "iam" {
  source = "./modules/iam"
}

module "cloudwatch" {
  source = "./modules/cloudwatch"
}

module "vpc" {
  source = "./modules/vpc"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}-data"
}

module "ecs" {
  source                     = "./modules/ecs"
  task_role_arn              = module.iam.ecs_role.arn
  execution_role_arn         = module.iam.ecs_role.arn
  cloud_watch_log_group_name = module.cloudwatch.log_group.name

  depends_on = [
    module.iam,
    module.cloudwatch
  ]
}

module "ecr" {
  source                 = "./modules/ecr"
  cross_account_role_arn = module.iam.ecs_role.arn

  depends_on = [
    module.iam
  ]
}
