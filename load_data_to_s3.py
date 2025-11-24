import logging
import boto3
from botocore.exceptions import ClientError
import os


def upload_directory_to_s3(root_dir_name: str, 
                           local_dir: str, 
                           bucket_name: str, 
                           s3_client: boto3.client):  
    """  
    Uploads an entire directory to an S3 bucket.  
 
    Args:  
        root_dir_name (str): Root name of the directory inside s3 where given files will be stored.
        local_dir (str): Path to the local directory to upload.  
        bucket_name (str): Name of the S3 bucket.  
        s3_client (boto3.client): Initialized S3 client.  
    """  
    # Traverse the local directory  
    for root, dirs, files in os.walk(local_dir):  
        for filename in files:  
            # Local file path  
            local_file_path = os.path.join(root, filename)  

            # S3 key: Preserve directory structure relative to LOCAL_DIRECTORY  
            # Example: If local_dir is 'docs' and file is 'docs/reports/2023.pdf',  
            # S3 key becomes 'reports/2023.pdf'  
            relative_path = os.path.relpath(local_file_path, local_dir)  
            s3_key = os.path.join(root_dir_name, relative_path).replace(os.sep, '/')  # Use '/' for S3 paths  

            try:  
                # Upload the file to S3  
                s3_client.upload_file(  
                    Filename=local_file_path,  
                    Bucket=bucket_name,  
                    Key=s3_key  
                )  
                print(f"Uploaded: {local_file_path} -> s3://{bucket_name}/{s3_key}")  
 
            except FileNotFoundError:  
                print(f"Error: The file {local_file_path} was not found.")  
            except NoCredentialsError:  
                print("Error: AWS credentials not found.")  
                return  
            except ClientError as e:  
                print(f"Error uploading {local_file_path}: {e}")  

if __name__ == "__main__":
    boto_client = boto3.client("s3")
    # upload_directory_to_s3("Hotels",
    #                        "./Spark/hotels", 
    #                        bucket_name="bronze-u3ra6oa", 
    #                        s3_client=boto_client)
    # upload_directory_to_s3("Weather",
    #                        "./Spark/weather/year=2016/month=10/", 
    #                        bucket_name="bronze-u3ra6oa", 
    #                        s3_client=boto_client)
    upload_directory_to_s3("Equity_ETFs",
                           "./Spark/equity_data",
                           bucket_name="bronze-u3ra6oa",
                           s3_client=boto_client)
    upload_directory_to_s3("GlueETLScript",
                           "./GlueScripts",
                           bucket_name="general-utility-38fnvu3nvc0",
                           s3_client=boto_client)
    upload_directory_to_s3("LambdaScripts",
                           "./LambdaScripts",
                           bucket_name="general-utility-38fnvu3nvc0",
                           s3_client=boto_client)
    upload_directory_to_s3("Equity_ETFs",
                            "./DataGenerationScripts",
                            bucket_name="silver-u3b9rvg",
                            s3_client=boto_client)