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

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "elasticache_sg_id" {
    description = "Security group ID for RElastiCache"
    type        = string
}