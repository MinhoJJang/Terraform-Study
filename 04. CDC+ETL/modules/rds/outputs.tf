# modules/rds/outputs.tf
output "rds_endpoint" {
  value       = split(":", aws_db_instance.default.endpoint)[0]
  description = "The endpoint of the RDS instance (without port)"
}

output "rds_port" {
  value       = aws_db_instance.default.port
  description = "The port of the RDS instance"
}

output "rds_instance_arn" {
  value       = aws_db_instance.default.arn
  description = "The ARN of the RDS instance"
}

output "username" {
  value       = aws_db_instance.default.username
  description = "The username of the RDS instance"
  sensitive   = true
}

output "password" {
  value       = var.password
  description = "The password of the RDS instance"
  sensitive   = true
}