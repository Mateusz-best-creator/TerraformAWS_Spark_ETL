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

variable "lambda_trigger_glue_equity_arn" {
  type = string
  description = "ARN value of the lambda function used to start GLUE job."
}

variable "lambda_run_glue_crawler_arn" {
  type = string
  description = "ARN value of the lambda function used to start GLUE crawler."
}

variable "lambda_run_sf_workflow_arn" {
  type = string
  description = "ARN value of the lambda function to start sf workflow."
}