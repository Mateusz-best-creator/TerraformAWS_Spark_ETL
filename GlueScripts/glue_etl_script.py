import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsgluedq.transforms import EvaluateDataQuality

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Default ruleset used by all target nodes with data quality enabled
DEFAULT_DATA_QUALITY_RULESET = """
    Rules = [
        ColumnCount > 0
    ]
"""

# Script generated for node Amazon S3
AmazonS3_node1763732303241 = glueContext.create_dynamic_frame.from_catalog(database="glue_hotel_weather_db", table_name="equity_etfs", transformation_ctx="AmazonS3_node1763732303241")

# Script generated for node Change Schema
ChangeSchema_node1763732420338 = ApplyMapping.apply(frame=AmazonS3_node1763732303241, mappings=[("date", "string", "report_date", "date"), ("spy", "double", "spy", "double"), ("ivv", "double", "ivv", "double"), ("xlg", "double", "xlg", "double"), ("qqq", "double", "qqq", "double"), ("vug", "double", "vug", "double"), ("iwf", "double", "iwf", "double"), ("iwm", "double", "iwm", "double"), ("iemg", "double", "iemg", "double"), ("iefa", "double", "iefa", "double"), ("ijh", "double", "ijh", "double"), ("ijr", "double", "ijr", "double"), ("schd", "double", "schd", "double"), ("rsp", "double", "rsp", "double"), ("xlk", "double", "xlk", "double"), ("xle", "double", "xle", "double"), ("xlf", "double", "xlf", "double")], transformation_ctx="ChangeSchema_node1763732420338")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=ChangeSchema_node1763732420338, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1763732297849", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1763732546547 = glueContext.getSink(path="s3://silver-u3b9rvg/Equity_ETFs/", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=["report_date"], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1763732546547")
AmazonS3_node1763732546547.setCatalogInfo(catalogDatabase="glue_hotel_weather_db",catalogTableName="equity_data_parquet")
AmazonS3_node1763732546547.setFormat("glueparquet", compression="snappy")
AmazonS3_node1763732546547.writeFrame(ChangeSchema_node1763732420338)
job.commit()