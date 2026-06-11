output "redis_endpoint" {
  description = "Primary endpoint for Redis connection"
  value       = aws_elasticache_replication_group.default.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.default.port
}

output "replication_group_id" {
  description = "Replication group ID for monitoring"
  value       = aws_elasticache_replication_group.default.id
}