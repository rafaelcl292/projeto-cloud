resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

module "RDS" {
  source      = "./modules/RDS"
  db_password = var.db_password
  vpc_id      = aws_vpc.vpc.id
}

module "LB" {
  source = "./modules/LB"
  vpc_id = aws_vpc.vpc.id
  igw   = aws_internet_gateway.igw
}

module "EC2" {
  source        = "./modules/EC2"
  lb_subnet_ids = module.LB.lb_subnet_ids
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.EC2.asg_name
  lb_target_group_arn    = module.LB.alb_target_group_arn
}
