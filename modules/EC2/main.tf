resource "aws_subnet" "subnet1_ec2" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1_ec2"
  }
}

resource "aws_route_table" "route_table_ec2" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "subnet1_ec2" {
  subnet_id      = aws_subnet.subnet1_ec2.id
  route_table_id = aws_route_table.route_table_ec2.id
}

resource "aws_launch_template" "launch_template" {
  name          = "launch_template_ec2"
  image_id      = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_ec2.key_name
  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt-get install -y apache2
    sudo systemctl enable apache2
    wget https://raw.githubusercontent.com/rafaelcl292/projeto-cloud/main/api/index.html
    sed 's/localhost/${aws_instance.api.public_ip}/g' index.html > index_new.html
    sudo mv index_new.html /var/www/html/index.html
    sudo systemctl start apache2
    EOF
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg_ec2.id]
    subnet_id                   = aws_subnet.subnet1_ec2.id
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ec2"
    }
  }
}

resource "aws_security_group" "sg_ec2" {
  name   = "sg_ec2"
  vpc_id = var.vpc_id

  # http
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # security_groups = [var.lb_sg]
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_autoscaling_group" "asg_ec2" {
  name                      = "asg_ec2"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 5
  vpc_zone_identifier       = [aws_subnet.subnet1_ec2.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  target_group_arns         = [var.lb_target_group_arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_key_pair" "key_ec2" {
  key_name   = "key_ec2"
  public_key = file("ec2.pem.pub")
}

resource "aws_cloudwatch_metric_alarm" "alarm_ec2_scale_up" {
  alarm_name          = "alarm_ec2_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.policy_ec2_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ec2.name
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_ec2_scale_down" {
  alarm_name          = "alarm_ec2_scale_down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.policy_ec2_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_ec2.name
  }
}

resource "aws_autoscaling_policy" "policy_ec2_scale_up" {
  name                   = "policy_ec2_scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_ec2.name
}

resource "aws_autoscaling_policy" "policy_ec2_scale_down" {
  name                   = "policy_ec2_scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_ec2.name
}

# api
resource "aws_security_group" "sg_api" {
  name   = "sg_api"
  vpc_id = var.vpc_id

  # http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "api" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_ec2.key_name
  subnet_id              = aws_subnet.subnet1_ec2.id
  vpc_security_group_ids = [aws_security_group.sg_api.id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    wget https://raw.githubusercontent.com/rafaelcl292/projeto-cloud/main/api/main
    chmod +x main
    export DB_PASSWORD=${var.db_password}
    export DB_HOST=${var.db_host}
    export DB_PORT=${var.db_port}
    export DB_NAME=${var.db_name}
    export DB_USER=${var.db_user}
    ./main
    EOF
  )

  tags = {
    Name = "api"
  }
}
