variable aws_region {
    type = string
    default = "eu-central-1"
    description = "Value of the AWS region where we deploy our resources"
}

variable aws_profile {
    type = string
    default = "terraform"
    description = "Profile name in AWS configuration"
}