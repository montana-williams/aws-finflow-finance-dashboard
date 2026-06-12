module "vpc" {
  source = "./modules/vpc"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_arn            = module.compute.alb_arn
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "compute" {
  source = "./modules/compute"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  app_sg_id          = module.security.app_sg_id
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  acm_certificate_arn = var.acm_certificate_arn
}

module "database" {
    source = "./modules/database"

    private_subnet_ids = module.vpc.private_subnet_ids
    project_name = var.project_name
    db_username = var.db_username
    db_password = var.db_password
    rds_sg_id = module.security.rds_sg_id
}

module "cache" {
    source = "./modules/cache"

    project_name = var.project_name
    environment = var.environment
    private_subnet_ids = module.vpc.private_subnet_ids
    elasticache_sg_id = module.security.elasticache_sg_id
}

module "auth" {
    source = "./modules/auth"

    project_name = var.project_name
    environment = var.environment
}

module "storage" {
    source = "./modules/storage"

    project_name = var.project_name
    environment = var.environment
    aws_account_id = var.aws_account_id
    app_role_arn = module.iam.app_role_arn
}

module "serverless" {
    source = "./modules/serverless"

    project_name = var.project_name
    environment = var.environment
    s3_bucket_name = module.storage.s3_bucket_name
    redis_endpoint = module.cache.redis_endpoint
    db_endpoint = module.database.db_endpoint
    lambda_sg_id = module.security.lambda_sg_id
    private_subnet_ids = module.vpc.private_subnet_ids
    aws_account_id = var.aws_account_id
}

module "monitoring" {
    source = "./modules/monitoring"

    project_name = var.project_name
    environment = var.environment
    aws_account_id = var.aws_account_id
    alert_email = var.alert_email
    lambda_dashboard_name = module.serverless.lambda_dashboard_name
    lambda_hourly_sync_name = module.serverless.lambda_hourly_sync_name
    lambda_reporting_name = module.serverless.lambda_reporting_name
    db_instance_identifier = module.database.db_instance_identifier
    dashboard_dlq_name = module.serverless.dashboard_dlq_name
    reporting_dlq_name = module.serverless.reporting_dlq_name
    cloudwatch_log_group_arn = var.cloudwatch_log_group_arn
    cloudtrail_role_arn = var.cloudtrail_role_arn
}