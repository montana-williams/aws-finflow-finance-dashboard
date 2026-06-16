output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "s3_bucket_name" {
  description = "The S3 bucket where CloudTrail logs are delivered"
  value       = aws_s3_bucket.cloudtrail.id
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value       = aws_sns_topic.alerts.arn
}