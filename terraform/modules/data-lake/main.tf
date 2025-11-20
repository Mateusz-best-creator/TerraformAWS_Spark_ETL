
resource "aws_s3_bucket" "s3_bronze_bucket" {
  bucket = var.s3_bronze_name
  force_destroy = true

  tags = {
    Name        = "Bronze layer bucket."
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
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 100
      storage_class = "DEEP_ARCHIVE"
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket" "s3_silver_bucket" {
  bucket = var.s3_silver_name
  force_destroy = true

  tags = {
    Name        = "Silver layer bucket."
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lifecycle_for_silver_layer" {
  bucket = aws_s3_bucket.s3_silver_bucket.id

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
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 100
      storage_class = "DEEP_ARCHIVE"
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket" "general_project_scripts_data" {
  bucket = "general_scripts_data_38fnvu3nvc0"
  force_destroy = true

  tags = {
    Name        = "Bucket where we store helper scripts, logs."
    Environment = "Dev"
  }
}