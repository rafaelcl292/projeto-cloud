resource "aws_subnet" "subnet1_app" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "lb_subnet"
  }
}

resource "aws_subnet" "subnet2_app" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "lb_subnet"
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb_security_group"
  description = "Load Balancer security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = [
    aws_subnet.subnet1_app.id,
    aws_subnet.subnet2_app.id,
  ]
  depends_on = [
    var.igw
  ]

  tags = {
    Name = "lb"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}

