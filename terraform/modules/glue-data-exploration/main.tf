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

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


resource "aws_iam_policy_attachment" "glue_s3_access" {
  name       = "glue-s3-access"
  roles      = [aws_iam_role.glue_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_glue_catalog_database" "equity_db" {
  name = "glue_equity_db"
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.hotel_weather_db.name
  name          = "weather-hotels-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.s3_bronze_name}/Equity_ETFs/"
    exclusions = [ "Hotels", "Weather", "Hotels/*", "Weather/*"]
  }
}

# Due to this error: failed to execute with exception Given GlueVersion [5.0] is not valid.
# This does not work and I cannot fix this.
# But it works with version 5.0 via management console so I did it there :).
# resource "aws_glue_job" "glue_equity_etfs_job" {
#   name        = "glue_equity_etfs_job"
#   role_arn    = aws_iam_role.glue_role.arn
#   glue_version = "5.0"

#   command {
#     name            = "glue_job"
#     script_location = "s3://${var.s3_general_utility_name}/scripts/glue_etl_script.py"
#   }
# }
