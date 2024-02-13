variable "public_subnet_cidrs" {
  type        = list(string)
  description = "public subnet cidr values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "private subnet cidr values"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "values of availability zones"
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}