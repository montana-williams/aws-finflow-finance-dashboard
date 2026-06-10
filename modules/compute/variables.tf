variable "project_name" {
  description = "Project name for naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Auto Scaling group"
  type        = list(string)
}

variable "alb_sg_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "target_group_arn" {
  description = "Target group ARN for Auto Scaling group"
  type        = string
}