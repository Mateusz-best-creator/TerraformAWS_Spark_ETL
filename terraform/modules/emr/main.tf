# --------------------------
# EMR service role (EMR control plane)
# --------------------------
resource "aws_iam_role" "emr_service_role" {
  name = "EMR_Service_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "elasticmapreduce.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# attach AWS-managed service-role policy to EMR service role
resource "aws_iam_role_policy_attachment" "emr_service_role_attachment" {
  role       = aws_iam_role.emr_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

# --------------------------
# EC2 instance role (the role EC2 instances assume — Spark processes use this)
# --------------------------
resource "aws_iam_role" "emr_ec2_role" {
  name = "EMR_EC2_Instance_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# attach a common, less-broad managed policy for EMR node behavior (optional)
resource "aws_iam_role_policy_attachment" "emr_ec2_managed" {
  role       = aws_iam_role.emr_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

# Inline, least-privilege S3 policy for your bronze & silver buckets
resource "aws_iam_role_policy" "emr_ec2_s3_policy" {
  name = "EMR_EC2_S3_Access"
  role = aws_iam_role.emr_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowListBuckets",
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = [
          var.s3_bronze_arn,
          var.s3_silver_arn
        ]
      },
      {
        Sid = "AllowObjectOps",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${var.s3_bronze_arn}/*",
          "${var.s3_silver_arn}/*"
        ]
      }
    ]
  })
}

# Create instance profile to attach to EC2 instances
resource "aws_iam_instance_profile" "emr_instance_profile" {
  name = "emr_instance_profile"
  role = aws_iam_role.emr_ec2_role.name
}

# --------------------------
# EMR cluster
# --------------------------
resource "aws_emr_cluster" "spark_cluster" {
  name          = "Spark Cluster"
  release_label = "emr-7.12.0"
  applications  = ["Spark", "Hadoop"]

  # this is the EMR service role (control plane)
  service_role = aws_iam_role.emr_service_role.arn

  ec2_attributes {
    instance_profile = aws_iam_instance_profile.emr_instance_profile.arn
  }

  master_instance_group {
    instance_type = "c4.large"
  }

  core_instance_group {
    # instance_type  = "c4.large"
    instance_type  = "t2.micro"
    instance_count = 1
  }

  visible_to_all_users = true
#   keep_job_flow_alive_when_no_steps = false

}
