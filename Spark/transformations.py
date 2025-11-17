from typing import Dict
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, median, mean, mode, udf
from geocode import GeocodeAPI
from pyspark.sql.types import StringType

class Transformations:

    def __init__(self):
        self.geocoder = GeocodeAPI()
        self.geohash_column_name = "GeoHash"
    
    def fill_missing_values(self, 
                            df: DataFrame, 
                            value_strategy_map: Dict[str, str]) -> DataFrame:
        for column_name, strategy_name in value_strategy_map.items():

            if strategy_name == "Delete":
                df = df.na.drop(subset=[column_name])

            elif strategy_name == "Mode":
                mode_value = df.select(mode(column_name)).collect()[0][0]
                df = df.fillna(value=mode_value, subset=[column_name])
            
            elif strategy_name == "Median":
                median_value = df.select(median(column_name)).collect()[0][0]
                df = df.fillna(value=median_value, subset=[column_name])
            
            elif strategy_name == "Mean":
                mean_value = df.select(mean(column_name)).collect()[0][0]
                df = df.fillna(value=mean_value, subset=[column_name])

            else:
                pass
        return df

    def geocode_row_using_address(self, 
                                  address: str, 
                                  city: str, 
                                  country: str):
        return self.geocoder.get_geohash_from_address_city_country(address, city, country)

    def geocode_row_using_lat_lon(self,
                                  latitude: float,
                                  longitude: float):
        return self.geocoder.get_geohash_from_lat_lon(latitude, longitude)

    def add_geohash(self,
                    df: DataFrame) -> DataFrame:
        if "Address" in df.columns:
            geocode_udf = udf(self.geocode_row_using_address, StringType())
            df = df.withColumn(self.geohash_column_name, 
                            geocode_udf(col("Address"), col("City"), col("Country")))
        else:
            geocode_udf = udf(self.geocode_row_using_lat_lon, StringType())
            df = df.withColumn(self.geohash_column_name,
                               geocode_udf(col("lat"), col("lng")))
        return df