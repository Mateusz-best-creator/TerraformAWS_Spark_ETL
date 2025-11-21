variable "s3_bronze_name" {
  description = "Name of the Bronze S3 bucket for the data lake"
  type        = string
}

variable "s3_silver_name" {
  description = "Name of the Silver S3 bucket for the data lake"
  type        = string
}

variable "s3_general_name" {
  description = "Name of the utility bucket where we store scripts, logs."
  type = string
}