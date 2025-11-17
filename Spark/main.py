from pyspark.sql import SparkSession
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--src", required=True)
parser.add_argument("--dest", required=True)
args = parser.parse_args()

spark = SparkSession.builder.appName("bronze-to-silver").getOrCreate()

df = spark.read.option("header","true").parquet(args.src)   # or csv/json etc.
df_clean = df.dropDuplicates()
df_clean.write.mode("overwrite").parquet(args.dest)

spark.stop()
