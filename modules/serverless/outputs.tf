output "lambda_dashboard_arn" {
  description = "ARN of the dashboard Lambda function"
  value       = aws_lambda_function.lambda_dashboard.arn
}

output "lambda_hourly_sync_arn" {
  description = "ARN of the hourly sync Lambda function"
  value       = aws_lambda_function.lambda_hourly_sync.arn
}

output "lambda_reporting_arn" {
  description = "ARN of the reporting Lambda function"
  value       = aws_lambda_function.lambda_reporting.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "hourly_sync_rule_arn" {
  description = "ARN of the hourly sync EventBridge rule"
  value       = aws_cloudwatch_event_rule.scheduled.arn
}

output "end_of_month_rule_arn" {
  description = "ARN of the end of month EventBridge rule"
  value       = aws_cloudwatch_event_rule.end_of_month.arn
}

output "lambda_dashboard_name" {
  description = "Name of the dashboard Lambda function"
  value       = aws_lambda_function.lambda_dashboard.function_name
}

output "lambda_hourly_sync_name" {
  description = "Name of the hourly sync Lambda function"
  value       = aws_lambda_function.lambda_hourly_sync.function_name
}

output "lambda_reporting_name" {
  description = "Name of the reporting Lambda function"
  value       = aws_lambda_function.lambda_reporting.function_name
}

output "dashboard_dlq_name" {
  description = "Name of the dashboard dead letter queue"
  value       = aws_sqs_queue.dashboard_dlq.name
}

output "reporting_dlq_name" {
  description = "Name of the reporting dead letter queue"
  value       = aws_sqs_queue.reporting_dlq.name
}