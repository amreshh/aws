variable "public_subnets" {
  type        = map(string)
  description = "public subnet cidrs"
  default = {
    eu-central-1a = "10.0.1.0/24"
    eu-central-1b = "10.0.2.0/24"
  }
}

variable "private_subnets" {
  type        = map(string)
  description = "private subnet cidrs"
  default = {
    eu-central-1a = "10.0.4.0/24"
    eu-central-1b = "10.0.5.0/24"
  }
}