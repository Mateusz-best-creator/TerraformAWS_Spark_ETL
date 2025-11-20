output "s3_bronze_arn" {
  value       = aws_s3_bucket.s3_bronze_bucket.arn
  description = "ARN of the bronze bucket."
}

output "s3_silver_arn" {
  value       = aws_s3_bucket.s3_silver_bucket.arn
  description = "ARN of the silver bucket."
}

output "s3_glue_etl_name" {
  value = aws_s3_bucket.glue_etl_bucket.name
  description = "Name of the glue bucket."
}