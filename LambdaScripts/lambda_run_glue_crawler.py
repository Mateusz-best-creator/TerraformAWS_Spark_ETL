import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
# Create a Lambda client
lambda_client = boto3.client('lambda')
# Create a glue client
client = boto3.client('glue')

crawler_name = "etfs-equity-crawler"
lambda_name = "RunEquityGlueJob"

# Define Lambda function
def lambda_handler(event, context):
    logger.info('## INITIATED BY EVENT: ')
    logger.info(event)
    response_glue = client.start_crawler(Name=crawler_name)
    logger.info('## STARTED GLUE CRAWLER: ' + crawler_name)
    response_lambda = lambda_client.invoke(
        FunctionName=lambda_name,
        InvocationType='RequestResponse',
    )
    logger.info('## STARTED LAMBDA FUNCTION: ' + lambda_name)
    return response_glue