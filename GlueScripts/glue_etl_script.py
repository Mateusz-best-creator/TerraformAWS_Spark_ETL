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
AmazonS3_node1763995682956 = glueContext.create_dynamic_frame.from_options(format_options={"quoteChar": "\"", "withHeader": True, "separator": ","}, connection_type="s3", format="csv", connection_options={"paths": ["s3://bronze-u3ra6oa/Equity_ETFs/"], "recurse": True}, transformation_ctx="AmazonS3_node1763995682956")

# Script generated for node Change Schema
ChangeSchema_node1763995752101 = ApplyMapping.apply(frame=AmazonS3_node1763995682956, mappings=[("Date", "string", "record_date", "date"), ("SPY", "string", "SPY", "string"), ("VOO", "string", "VOO", "string"), ("IVV", "string", "IVV", "string"), ("VTI", "string", "VTI", "string"), ("QQQ", "string", "QQQ", "string"), ("VUG", "string", "VUG", "string"), ("IWF", "string", "IWF", "string"), ("IWM", "string", "IWM", "string"), ("VEA", "string", "VEA", "string"), ("VXUS", "string", "VXUS", "string"), ("VWO", "string", "VWO", "string"), ("IEMG", "string", "IEMG", "string"), ("IEFA", "string", "IEFA", "string"), ("IJH", "string", "IJH", "string"), ("VO", "string", "VO", "string"), ("IJR", "string", "IJR", "string"), ("VTV", "string", "VTV", "string"), ("VIG", "string", "VIG", "string"), ("SCHD", "string", "SCHD", "string"), ("RSP", "string", "RSP", "string"), ("VGT", "string", "VGT", "string")], transformation_ctx="ChangeSchema_node1763995752101")

# Script generated for node Amazon S3
EvaluateDataQuality().process_rows(frame=ChangeSchema_node1763995752101, ruleset=DEFAULT_DATA_QUALITY_RULESET, publishing_options={"dataQualityEvaluationContext": "EvaluateDataQuality_node1763995628883", "enableDataQualityResultsPublishing": True}, additional_options={"dataQualityResultsPublishing.strategy": "BEST_EFFORT", "observations.scope": "ALL"})
AmazonS3_node1763995807959 = glueContext.getSink(path="s3://silver-u3b9rvg/Equity_ETFs/", connection_type="s3", updateBehavior="UPDATE_IN_DATABASE", partitionKeys=[], enableUpdateCatalog=True, transformation_ctx="AmazonS3_node1763995807959")
AmazonS3_node1763995807959.setCatalogInfo(catalogDatabase="glue_equity_db",catalogTableName="equity_data_prepared")
AmazonS3_node1763995807959.setFormat("glueparquet", compression="snappy")
AmazonS3_node1763995807959.writeFrame(ChangeSchema_node1763995752101)
job.commit()