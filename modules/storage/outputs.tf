output "bucket_arn" {
  description = "S3 bucket ARN — pass to IAM policies and CloudTrail"
  value       = aws_s3_bucket.main.arn
}

output "s3_bucket_name" {
  description = "S3 bucket name — pass to Lambda environment variables"
  value       = aws_s3_bucket.main.id
}