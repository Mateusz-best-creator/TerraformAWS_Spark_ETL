provider "aws" {
  region = "us-east-1"
}

terraform {
    backend "s3" {
        bucket = "terraform-up-and-running-state"
        key = "terraform-state"
        region = ""
    }
}

resource "aws_s3_bucket" "terraform-state-bucket" {
  bucket = "terraform-up-and-running-state"

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}