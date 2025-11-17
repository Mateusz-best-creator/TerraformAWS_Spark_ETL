#!/bin/bash

# script_input_bucket='s3://my-bucket/scripts/my_spark_job.py'
# bronze_bucket='s3://bronze-u3ra6oa/raw_data/'
# silver_bucket='s3://silver-u3b9rvg/cleaned_data/'

aws emr add-steps \
  --cluster-id j-181BS8SO2ZQMS \
  --steps "Type=Spark,Name=MySparkJob,ActionOnFailure=CONTINUE,Args=[--deploy-mode,cluster,--conf,spark.yarn.submit.waitAppCompletion=true,s3://spark-scripts-jd7v53c/main.py,s3://bronze-u3ra6oa/raw_data/,s3://silver-u3b9rvg/cleaned_data/]"