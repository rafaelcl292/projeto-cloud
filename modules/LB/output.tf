output "alb_target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "load_balancer_dns" {
  value = aws_lb.lb.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.lb_sg.id
}
