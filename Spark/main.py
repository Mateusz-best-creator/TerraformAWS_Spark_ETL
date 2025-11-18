from pyspark.sql import SparkSession
from transformations import Transformations
from typing import Literal

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

    def transform(self):
        transformations = Transformations()
        self.weather_df = transformations.fill_missing_values(self.weather_df,
                                                            {"lng": "Delete",
                                                            "lat": "Delete",
                                                            "avg_tmpr_f": "Median",
                                                            "avg_tmpr_c": "Median",
                                                            "wthr_date": "Delete",
                                                            "year": "Median",
                                                            "month": "Median",
                                                            "day": "Median"})
        self.hotels_df = transformations.fill_missing_values(self.hotels_df,
                                                            {"Id": "Mean",
                                                            "Name": "Delete",
                                                            "Country": "Mode",
                                                            "City": "Mode",
                                                            "Address": "Delete",
                                                            "Latitude": "Median",
                                                            "Longitude": "Median"})
        self.weather_df = transformations.add_geohash(self.weather_df)
        self.hotels_df = transformations.add_geohash(self.hotels_df)
        self.hotels_df.show(5)
        self.weather_df.show(5)
        print(f"\n\n\nStarting grouping transformations\n\n\n")
        self.weather_df = transformations.group_weather_dataset(self.weather_df)
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

    spark = SparkSession.builder \
            .appName("SparkETL") \
            .master("local[*, 4]") \
            .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")

    etl_job = ETL(spark,
                  hotels_dataset_path="./hotels",
                  weather_dataset_path="./weather")
    etl_job()