resource "aws_iam_role" "glue_role" {
  name = "glue-etl-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "glue.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "glue_s3_access" {
  name       = "glue-s3-access"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_glue_catalog_database" "hotel_weather_db" {
  name = "glue_hotel_weather_db"
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.example.name
  name          = "weather-hotels-crawler"
  role          = aws_iam_role.example.arn

  s3_target {
    path = "s3://${var.s3_bronze_name}"
  }
}

resource "aws_glue_job" "glue_hotel_weather_etl_job" {
  name        = "glue_hotel_weather_etl_job"
  role_arn    = aws_iam_role.glue_role.arn

  command {
    name            = "glue_etl"
    script_location = "s3://${var.s3_glue_bucket_name}/scripts/etl_script.py"
    python_version  = "3"
  }
}