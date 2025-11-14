
output "mysql_login_command" {
  description = "Command to login to the company MySQL database"
  value       = "mysql -h ${aws_db_instance.company_db.address} -P ${aws_db_instance.company_db.port} -u ${var.company_db_username} -p ${var.company_db_password}"
  sensitive   = true
}
