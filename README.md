# Terraform/Spark AWS Mini Project

The goal of this project is to practice the following:

1. Creating infrastructure as code (IaC) using Terraform on AWS.
2. Becoming more familiar with AWS services commonly used for ETL pipelines.
3. Practicing PySpark by creating simple ETL scripts for cleaning data.

The objective is to ingest data into an S3 bronze bucket using services such as AWS DMS and a SDK for python for copying data from a local machine into the bronze bucket. Then, an AWS EMR cluster will be set up to run Spark scripts that clean the data and write it to the silver S3 bucket. After that, the Redshift `COPY` command will be used to load data from the silver bucket into Amazon Redshift, where business level aggregations will be performed. Once meaningful insights are derived in Redshift, Amazon QuickSight will be used to visualize the data and create a polished dashboard.

The architecture will look as follows:

<img src="./architecture.png">

# How to Run the Project Yourself

1. First, run: `aws configure --profile terraform`. This will prompt you to enter your access key ID and secret access key. Remember never to share these keys with anyone! After completing this step, you can inspect your `.aws` folder and confirm that your credentials are stored there. This configuration allows Terraform to communicate with your AWS account.

2. Create the infrastructure:

    - `terraform init`
    - `terraform plan -out terraform.plan`
    - `terraform apply terraform.plan`
