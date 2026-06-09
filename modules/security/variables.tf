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

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
}