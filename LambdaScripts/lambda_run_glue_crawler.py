import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('glue')
crawler_name = "etfs-equity-crawler"

# Define Lambda function
def lambda_handler(event, context):
    logger.info('## INITIATED BY EVENT: ')
    logger.info(event)
    response = client.start_crawler(Name=crawler_name)
    logger.info('## STARTED GLUE CRAWLER: ' + crawler_name)
    return response