import os
from dotenv import load_dotenv 
import pyspark.sql.functions as sf
from pyspark.sql import DataFrame
from typing import List

class Encrpytion:

    def __init__(self):
        load_dotenv("../.env") 
        self.key = os.getenv("EncryptionKey")

    def encrypt_data(self,
                     df: DataFrame,
                     columns_to_encrypt: List[str]) -> DataFrame:
        for column in columns_to_encrypt:
            encoded_column = sf.aes_encrypt(df.select(sf.col(column)), self.key)
            df = df.withColumn(column, encoded_column)
        return df

    def decrypt_data(self,
                     df: DataFrame,
                     columns_to_decrypt: List[str]) -> DataFrame:
        for column in columns_to_decrypt:
            decoded_column = sf.aes_decrypt(df.select(sf.col(column)), self.key)
            df = df.withColumn(column, decoded_column)
        return df