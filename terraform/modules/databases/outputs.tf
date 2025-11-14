
output "mysql_login_command" {
  description = "Command to login to the employee MySQL database"
  value       = "mysql -h ${aws_db_instance.employee_db.address} -P ${aws_db_instance.employee_db.port} -u ${var.employee_db_username} -p ${var.employee_db_password}"
  sensitive   = true
}
