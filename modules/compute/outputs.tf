output "asg_name" {
  description = "The name of the Auto Scaling group"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "alb_arn" {
  description = "ARN of the ALB for WAF association"
  value       = aws_lb.finflow_alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.finflow_alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group — pass to Auto Scaling module"
  value       = aws_lb_target_group.main.arn
}