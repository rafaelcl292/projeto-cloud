output "ec2_asg_arn" {
 value = aws_autoscaling_group.asg_ec2.arn
}

output "asg_name" {
  value = aws_autoscaling_group.asg_ec2.name
}
