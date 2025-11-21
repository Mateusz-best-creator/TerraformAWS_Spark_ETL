output "s3_bronze_arn" {
  value       = aws_s3_bucket.s3_bronze_bucket.arn
  description = "ARN of the bronze bucket."
}

output "s3_silver_arn" {
  value       = aws_s3_bucket.s3_silver_bucket.arn
  description = "ARN of the silver bucket."
}

output "s3_general_arn" {
  value = aws_s3_bucket.general_utility.arn
  description = "ARN of the glue bucket."
}