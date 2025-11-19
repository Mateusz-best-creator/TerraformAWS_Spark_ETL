import os
from dotenv import load_dotenv 
import pyspark.sql.functions as sf
from pyspark.sql import DataFrame
from typing import List, Dict

class Encryption:

    def __init__(self):
        load_dotenv("../.env") 
        self.key = sf.lit(os.getenv("EncryptionKey")).cast("binary")

    def encrypt_data(self,
                     df: DataFrame,
                     columns_to_encrypt: List[str]) -> DataFrame:
        for column in columns_to_encrypt:
            encoded_column = sf.aes_encrypt(df[column].cast("string"), self.key)
            df = df.withColumn(column, encoded_column)
        return df

    def decrypt_data(self,
                     df: DataFrame,
                     columns_to_decrypt_with_original_type: Dict[str, str]) -> DataFrame:
        for column_name, original_type in columns_to_decrypt_with_original_type.items():
            decoded_column = sf.aes_decrypt(df[column_name], self.key).cast("string").cast(original_type)
            df = df.withColumn(column_name, decoded_column)
        return df