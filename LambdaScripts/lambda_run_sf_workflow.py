import boto3
import os 
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('stepfunctions')
state_machine_arn = "spark_cluster"
state_machine_name = "spark_cluster"

def lambda_handler(event, context):
    logger.info('## INITIATED BY EVENT: ')
    logger.info(event)
    response = client.start_execution(
        stateMachineArn=state_machine_arn,
        name=state_machine_name,
    )
    logger.info('## STARTED SF WORKFLOW: ' + glueJobName)
    return response