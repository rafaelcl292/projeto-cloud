resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
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
  source          = "./modules/RDS"
  vpc_id          = aws_vpc.vpc.id
}

module "LB" {
  source = "./modules/LB"
  vpc_id = aws_vpc.vpc.id
  igw    = aws_internet_gateway.igw
}

module "EC2" {
  source              = "./modules/EC2"
  vpc_id              = aws_vpc.vpc.id
  lb_target_group_arn = module.LB.alb_target_group_arn
  lb_sg               = module.LB.alb_sg_id
  igw                 = aws_internet_gateway.igw
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = module.EC2.asg_name
  lb_target_group_arn    = module.LB.alb_target_group_arn
}
