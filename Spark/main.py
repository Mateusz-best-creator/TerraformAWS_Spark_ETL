from pyspark.sql import SparkSession
from transformations import Transformations
from typing import Literal
from encryption import Encryption
from pyspark.sql.types import StringType, DoubleType
import os
from dotenv import load_dotenv 

class ETL:

    def __init__(self,
                 spark: SparkSession,
                 hotels_dataset_path: str,
                 weather_dataset_path: str,
                 weather_df_save_path: str = "cleaned_data/weather",
                 hotel_df_save_path: str = "cleaned_data/hotels"):
        self.spark = spark
        self.hotels_dataset_path = hotels_dataset_path
        self.weather_dataset_path = weather_dataset_path
        self.hotels_df, self.weather_df = None, None

        self.weather_df_save_path = weather_df_save_path
        self.hotel_df_save_path = hotel_df_save_path

    def extract(self):
        self.hotels_df = spark.read.csv(self.hotels_dataset_path, header=True)
        self.weather_df = spark.read.parquet(self.weather_dataset_path)
        self.hotels_df.show(5)
        self.weather_df.show(5)

    def transform(self):
        print(f"Starting transformations!")
        transformations = Transformations()
        self.weather_df = transformations.fill_missing_values(self.weather_df,
                                                            {"lng": "Delete",
                                                            "lat": "Delete",
                                                            "avg_tmpr_f": "Median",
                                                            "avg_tmpr_c": "Median",
                                                            "wthr_date": "Delete"})
        self.weather_df = transformations.fill_year_month_day(self.weather_df)
        self.hotels_df = transformations.fill_missing_values(self.hotels_df,
                                                            {"Id": "Mean",
                                                            "Name": "Delete",
                                                            "Country": "Mode",
                                                            "City": "Mode",
                                                            "Address": "Delete",
                                                            "Latitude": "Median",
                                                            "Longitude": "Median"})
        # self.weather_df = transformations.add_geohash(self.weather_df)
        # self.hotels_df = transformations.add_geohash(self.hotels_df)
        # self.weather_df = transformations.filter_geohash(self.weather_df)
        # self.hotels_df = transformations.filter_geohash(self.hotels_df)
        # print(f"After imputing2")
        # self.hotels_df.show(5)
        # self.weather_df.show(5)
        # print(f"\n\n\nStarting grouping transformations\n\n\n")
        # self.weather_df = transformations.group_weather_dataset(self.weather_df)
        self.hotels_df.show(5)
        self.weather_df.show(5)

        encryption_class = Encryption()
        self.hotels_df = encryption_class.encrypt_data(self.hotels_df,
                                                      ["Name", "Country", 
                                                      "City", "Address", 
                                                      "Latitude", "Longitude"])
        self.weather_df = encryption_class.encrypt_data(self.weather_df,
                                                        {"lng", "lat"})
        print(f"\n\nAfter encryption:\n\n")
        self.hotels_df.show(5)
        self.weather_df.show(5)
        self.hotels_df = encryption_class.decrypt_data(self.hotels_df,
                                                      {"Name": StringType(), "Country": StringType(), 
                                                      "City": StringType(), "Address": StringType(), 
                                                      "Latitude": DoubleType(), "Longitude": DoubleType()})
        self.weather_df = encryption_class.decrypt_data(self.weather_df,
                                                        {"lng": DoubleType(), "lat": DoubleType()})
        self.hotels_df.show(5)
        self.weather_df.show(5)

    def load(self,
             write_mode: Literal["append", "overwrite", "ignore", "error"] = "overwrite"):
        print(f"Saving weather dataset to: {self.weather_df_save_path}")
        self.weather_df.write.parquet(path=self.weather_df_save_path, 
                                      mode=write_mode,
                                      partitionBy=["year", "month", "day"])
        print(f"Saving hotel dataset to: {self.hotel_df_save_path}")
        self.hotels_df.write.parquet(path=self.hotel_df_save_path,
                                     mode=write_mode)

    def __call__(self):
        self.extract()
        self.transform()
        self.load()

if __name__ == "__main__":

    load_dotenv(dotenv_path="../.env")
    AWS_ACCESS_KEY = os.getenv("ACCESS_KEY")
    AWS_SECRET_KEY = os.getenv("SECRET_ACCESS_KEY")
    BRONZE_BUCKET_NAME = os.getenv("BRONZE_BUCKET_NAME")
    SILVER_BUCKET_NAME = os.getenv("SILVER_BUCKET_NAME")

    spark = SparkSession.builder \
        .appName("S3SparkIntegration") \
        .master("local[*]") \
        .config("spark.hadoop.fs.s3a.access.key", AWS_ACCESS_KEY) \
        .config("spark.hadoop.fs.s3a.secret.key", AWS_SECRET_KEY) \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.jars.packages", 
                "org.apache.hadoop:hadoop-aws:3.3.2,"
                "com.amazonaws:aws-java-sdk-bundle:1.12.262") \
        .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    s3_bronze_bucket_weather_path = f"s3a://{BRONZE_BUCKET_NAME}/Weather/"
    s3_bronze_bucket_hotels_path = f"s3a://{BRONZE_BUCKET_NAME}/Hotels/"
    s3_silver_bucket_weather_path = f"s3a://{SILVER_BUCKET_NAME}/Weather/"
    s3_silver_bucket_hotels_path = f"s3a://{SILVER_BUCKET_NAME}/Hotels/"

    # spark = SparkSession.builder \
    #     .appName("S3SparkIntegration") \
    #     .master("local[*]") \
    #     .getOrCreate()
    # spark.sparkContext.setLogLevel("ERROR")

    # s3_bronze_bucket_hotels_path = f"./hotels/"
    # s3_bronze_bucket_weather_path = f"./weather/year=2016/month=10/"
    # s3_silver_bucket_weather_path = f"./cleaned_data/weather"
    # s3_silver_bucket_hotels_path = f"./cleaned_data/hotels"


    etl_job = ETL(spark,
                  hotels_dataset_path=s3_bronze_bucket_hotels_path,
                  weather_dataset_path=s3_bronze_bucket_weather_path,
                  hotel_df_save_path=s3_silver_bucket_hotels_path,
                  weather_df_save_path=s3_silver_bucket_weather_path)
    etl_job()