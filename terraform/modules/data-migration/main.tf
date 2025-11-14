
resource "aws_iam_role" "AmazonS3WriteRole" {
  name = "AmazonS3WriteRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "dms.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "AmazonS3WriteRoleAttachement" {
  role       = aws_iam_role.AmazonS3WriteRole.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
    Effect   = "Allow",
    Action   = ["s3:PutObject", "s3:ListBucket"],
    Resource = [
        var.s3_bronze_arn,
        "${var.s3_bronze_arn}/*" # All objects inside
    ]
    }]
  })
}

# resource "aws_dms_replication_instance" "example" {
#   replication_instance_id   = "dms-instance"
#   replication_instance_class = "dms.t3.micro"
#   allocated_storage         = 10
#   publicly_accessible       = false
#   # vpc_security_group_ids     = [...] # same as RDS
#   # replication_subnet_group_id = aws_dms_replication_subnet_group.example.id
# }
