output "alb_dns_name" {
  description = "ALB DNS name — this is your application URL"
  value       = module.compute.alb_dns_name
}

output "db_endpoint" {
  description = "RDS primary endpoint"
  value       = module.database.db_endpoint
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.cache.redis_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket for PDF reports"
  value       = module.storage.s3_bucket_name
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.auth.user_pool_id
}

output "cloudtrail_arn" {
  description = "CloudTrail trail ARN"
  value       = module.monitoring.trail_arn
}