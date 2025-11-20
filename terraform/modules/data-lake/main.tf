
resource "aws_s3_bucket" "s3_bronze_bucket" {
  bucket = var.s3_bronze_name

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

resource "aws_s3_bucket" "spark_files_for_EMR" {
  bucket = "spark-scripts-jd7v53c"

  tags = {
    Name        = "Bucket where we store spark scripts that transforms from bronze to silver layer."
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "glue_etl_bucket" {
  bucket = "glue_etl_bucket_asjv73g"

  tags = {
    Name        = "Bucket where we store aws glue and temp files."
    Environment = "Dev"
  }
}