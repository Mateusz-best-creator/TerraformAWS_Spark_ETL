
# I decided to keep s3 resource in the root main.tf and all other 
# s3 buckets that create data-lake solution inside data-lake module
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-up-and-running-statefbv5wz"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false
    # prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_account_public_access_block" "state_public_access" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "data_lake_solution" {
  source = "./modules/data-lake"

  s3_bronze_name = var.s3_bronze_bucket_name
  s3_silver_name = var.s3_silver_bucket_name
}

module "databases_solution" {
  source = "./modules/databases"

  default_vpc_id = data.aws_vpc.default.id
  # default_vpc_subnets = data.aws_subnets.default.ids
}

module "data_migration_solution" {
  source = "./modules/data-migration"

  s3_bronze_arn = module.data_lake_solution.s3_bronze_arn
}

# module "emr_cluster" {
#   source = "./modules/emr"

#   s3_bronze_arn = module.data_lake_solution.s3_bronze_arn
#   s3_silver_arn = module.data_lake_solution.s3_silver_arn
# }