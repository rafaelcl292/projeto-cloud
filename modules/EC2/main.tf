resource "aws_launch_configuration" "app_config" {
  name = "app_config"
  image_id = "ami-03d390062ea11f660"
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name = "app_asg"
  min_size = 1
  max_size = 3
  desired_capacity = 1
  launch_configuration = aws_launch_configuration.app_config.name
  vpc_zone_identifier = var.lb_subnet_ids
  health_check_type = "EC2"
  health_check_grace_period = 300
  force_delete = true
}

resource "aws_cloudwatch_metric_alarm" "app_alarm" {
  alarm_name = "app_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "70"
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions = [aws_autoscaling_policy.app_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

resource "aws_autoscaling_policy" "app_policy" {
  name = "app_policy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}
