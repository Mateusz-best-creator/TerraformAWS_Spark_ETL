import os
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)
client = boto3.client('glue')
glueJobName = "EquityDataPreparation"

# Define Lambda function
def lambda_handler(event, context):
    logger.info('## INITIATED BY EVENT: ')
    logger.info(event['detail'])
    response = client.start_job_run(JobName=glueJobName,
                                    WorkerType='G.1X',
                                    NumberOfWorkers=2)
    ExecutionClass='FLEX'
    logger.info('## STARTED GLUE JOB: ' + glueJobName)
    logger.info('## GLUE JOB RUN ID: ' + response['JobRunId'])
    return response