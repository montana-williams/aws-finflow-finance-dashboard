output "app_role_arn" {
  description = "The ARN of the application service role"
  value       = aws_iam_role.app_role.arn
}

output "app_role_name" {
  description = "The name of the application service role"
  value       = aws_iam_role.app_role.name
}

output "instance_profile_name" {
  description = "EC2 instance profile name — pass to compute module"
  value       = aws_iam_instance_profile.app_profile.name
}