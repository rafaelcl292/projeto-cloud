variable "db_password" {
  type        = string
  description = "Database password"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "cidr_blocks_ec2" {
  type        = list(string)
  description = "CIDR blocks for EC2 instances"
}
