output "alb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "lb_subnet_ids" {
  value = [
    aws_subnet.subnet1_app.id,
    aws_subnet.subnet2_app.id
  ]
}
