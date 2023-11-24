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
