
output "aws_region" {
  value       = var.aws_region
  description = "AWS region where we deploy our resources."
}

output "mysql_login_command" {
  value       = module.databases_solution.mysql_login_command
  description = "Command to login to the MySQL database"
  sensitive   = true
}
