from typing import Dict
from pyspark.sql import DataFrame
from pyspark.sql.functions import col, median, mean, mode

class Transformations:

    def __init__(self):
        pass
    
    def fill_missing_values(self, 
                            df: DataFrame, 
                            value_strategy_map: Dict[str, str]):
        for column_name, strategy_name in value_strategy_map.items():

            if strategy_name == "Delete":
                df = df.na.drop(subset=[column_name])

            elif strategy_name == "Mode":
                mode_value = df.select(mode(column_name)).collect()[0][0]
                print(f"Mode value = {mode_value}")
                df = df.fillna(value=mode_value, subset=[column_name])
            
            elif strategy_name == "Median":
                median_value = df.select(median(column_name)).collect()[0][0]
                print(f"Median value = {median_value}")
                df = df.fillna(value=median_value, subset=[column_name])
            
            elif strategy_name == "Mean":
                mean_value = df.select(mean(column_name)).collect()[0][0]
                print(f"Mean value = {mean_value}")
                df = df.fillna(value=mean_value, subset=[column_name])

            else:
                pass

    def add_geohash(self,
                    df: DataFrame):
        pass