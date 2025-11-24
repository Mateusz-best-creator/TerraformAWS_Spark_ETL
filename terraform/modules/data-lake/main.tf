
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

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_trigger_glue_equity_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bronze_bucket.arn
}


resource "aws_s3_bucket_notification" "upload_equity_data" {
  bucket = var.s3_bronze_name

  lambda_function {
    lambda_function_arn = var.lambda_run_glue_crawler_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "Equity_ETFs/"
    filter_suffix = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket, aws_s3_bucket.s3_bronze_bucket]
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

resource "aws_s3_bucket" "general_utility" {
  bucket = var.s3_general_name
  force_destroy = true

  tags = {
    Name        = "Utility bucket"
    Environment = "Dev"
  }
}