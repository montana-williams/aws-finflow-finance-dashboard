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
  description = "Private subnet IDs for Auto Scaling group"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "Security group ID for RDS"
  type        = string
}

variable "db_username" {
    description = "Username for RDS Database"
    type        = string
}

variable "db_password" {
    description = "Password for RDS Database"
    type        = string
    sensitive   = true
}