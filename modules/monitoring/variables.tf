variable "project_name" {
  description = "Project name for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_account_id" {
  description = "AWS account ID for globally unique bucket naming"
  type        = string
}

variable "alert_email" {
  description = "Email address for SNS alarm notifications"
  type        = string
}

variable "lambda_dashboard_name" {
  description = "Name of the dashboard Lambda function"
  type        = string
}

variable "lambda_hourly_sync_name" {
  description = "Name of the hourly sync Lambda function"
  type        = string
}

variable "lambda_reporting_name" {
  description = "Name of the reporting Lambda function"
  type        = string
}

variable "db_instance_identifier" {
  description = "RDS instance identifier for CloudWatch alarms"
  type        = string
}

variable "dashboard_dlq_name" {
  description = "Name of the dashboard dead letter queue"
  type        = string
}

variable "reporting_dlq_name" {
  description = "Name of the reporting dead letter queue"
  type        = string
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch log group for CloudTrail"
  type        = string
}

variable "cloudtrail_role_arn" {
  description = "IAM role ARN allowing CloudTrail to write to CloudWatch Logs"
  type        = string
}