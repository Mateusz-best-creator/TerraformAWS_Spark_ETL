output "s3_bronze_arn" {
    value = aws_s3_bucket.s3_bronze_bucket.arn
    description = "ARN of the bronze bucket."
}