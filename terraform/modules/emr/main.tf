
resource "aws_iam_role" "EMR_Allow_S3_Operations" {
  name = "EMR_S3_Operations"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "elasticmapreduce.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "emr-role"
  }
}

resource "aws_iam_role_policy" "AmazonS3WriteRoleAttachement" {
  role       = aws_iam_role.EMR_Allow_S3_Operations.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
    Effect   = "Allow",
    Action   = ["s3:PutObject", "s3:ListBucket", "s3:PutObject"],
    Resource = [
        var.s3_silver_arn,
        "${var.s3_silver_arn}/*" # All objects inside
    ]
    }]
  })
}