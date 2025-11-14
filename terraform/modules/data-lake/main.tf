
resource "aws_s3_bucket" "s3_bronze_bucket" {
    bucket = var.s3_bronze_name

    tags = {
        Name = "Bronze layer bucket."
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lifecycle_for_bronze_layer" {
    bucket = aws_s3_bucket.s3_bronze_bucket.id

    rule {
        id = "all_data"

        filter {
            # Apply to all objects
            prefix = ""
        }

        expiration {
            days = 365
        }

        transition {
            days = 30
            storage_class = "ONEZONE_IA"
        }

        transition {
            days = 100
            storage_class = "DEEP_ARCHIVE"
        }

        status = "Enabled"
    }
}