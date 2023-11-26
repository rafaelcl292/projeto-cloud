variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "lb_target_group_arn" {
  description = "Target Group ARN"
}

variable "lb_sg" {
  description = "Security Group for the Load Balancer"
}

variable "igw" {
  description = "Internet Gateway"
}

variable "db_password" {
  description = "Password for the database"
}

variable "db_host" {
  description = "Database Host"
}

variable "db_port" {
  description = "Database Port"
}

variable "db_name" {
  description = "Database Name"
}

variable "db_user" {
  description = "Database User"
}
