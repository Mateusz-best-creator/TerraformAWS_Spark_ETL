
# I decided to keep s3 resource in the root main.tf and all other 
# s3 buckets that create data-lake solution inside data-lake module
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terraform-up-and-running-statefbv5wz"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
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
  
}