variable "execution_role_arn" {
  type        = string
  description = "permissions assumed by the containers running the task"
}

variable "task_role_arn" {
  type        = string
  description = "permissions ecs needs to pull and run the task"
}

variable "cloud_watch_log_group_name" {
  type        = string
  description = "log group to send task logs"
}
