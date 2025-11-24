
# Changing terraform backend require executing "terraform init"
terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-statefbv5wz"
    key    = "terraform-state"
    # Enable state locking
    use_lockfile = true
    region       = "eu-central-1"
  }
}

