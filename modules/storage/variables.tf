variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "finflow"
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "aws_account_id" {
  description = "AWS account ID for globally unique bucket naming"
  type        = string
}

variable "app_role_arn" {
  description = "IAM role ARN for EC2 app instances to access S3"
  type        = string
}