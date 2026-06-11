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

variable "s3_bucket_name" {
  description = "S3 bucket name — pass to Lambda environment variables"
  type        = string
}

variable "redis_endpoint" {
  description = "Primary endpoint for Redis connection"
  type        = string
}

variable "db_endpoint" {
  description = "The connection endpoint for the database"
  type        = string
}

variable "lambda_sg_id" {
  description = Security Group ID for Lambda"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Auto Scaling group"
  type        = list(string)
}

variable "aws_account_id" {
  description = "AWS account ID for globally unique bucket naming"
  type        = string
}