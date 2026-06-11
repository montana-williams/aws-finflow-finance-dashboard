resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"           
  subnet_ids = var.private_subnet_ids     


  tags = {
    Name        = "${var.project_name}-cache"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_elasticache_parameter_group" "default" {
  name   = var.project_name
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "latency-tracking"
    value = "yes"
  }
}

resource "aws_elasticache_replication_group" "default" {
  automatic_failover_enabled  = true
  multi_az_enabled            = true
  subnet_group_name           = aws_elasticache_subnet_group.main.name
  security_group_ids          = [var.elasticache_sg_id]
  engine_version              = "7.0"
  preferred_cache_cluster_azs = ["us-east-1a", "us-east-1b"]
  replication_group_id        = "${var.project_name}-redis"
  description                 = "${var.project_name} Redis replication group"
  node_type                   = "cache.t3.micro"
  num_cache_clusters          = 2
  parameter_group_name        = aws_elasticache_parameter_group.default.name
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
}