

variable "company_db_password" {
  type        = string
  description = "Password to access database where we store company data."
  default     = "Andrzej2004!"
}

variable "company_db_username" {
  type        = string
  description = "Username for company database."
  default     = "admin"
}

variable "default_vpc_id" {
  type        = string
  description = "ID of the default VPC associated to my AWS account"
}

# variable "default_vpc_subnets" {
#     type = list(string)
#     description = "List of subnets"
# }

variable "mysql_port" {
  type        = number
  description = "MYSQL port"
  default     = 3306
}

variable "my_public_ip" {
  type        = string
  description = "MY IP"
  default     = "178.19.184.142/32"
}