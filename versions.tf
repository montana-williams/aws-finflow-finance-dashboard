terraform {
  required_version = ">= 1.7.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.100.0"
    }
  }

  backend "s3" {
    bucket         = "finflow-terraform-state-11006"
    key            = "finflow/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "finflow-terraform-locks"
    encrypt        = true
  }
}