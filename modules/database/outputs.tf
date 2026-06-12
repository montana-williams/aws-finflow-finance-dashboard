output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}

output "db_replica_endpoint" {
  description = "The connection endpoint for the read replica"
  value       = aws_db_instance.replica.endpoint
}

output "db_instance_identifier" {
  description = "RDS instance identifier for CloudWatch alarms"
  value       = aws_db_instance.main.identifier
}