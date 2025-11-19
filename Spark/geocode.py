import os
from dotenv import load_dotenv, dotenv_values 
from typing import Tuple
from opencage.geocoder import OpenCageGeocode

class GeocodeAPI:

    def __init__(self):
        load_dotenv("../.env") 
        self.key = os.getenv("GeocodeKey")
        self.geocoder = OpenCageGeocode(self.key)
        self.geohash_precision = 5

    def get_geohash_from_address_city_country(self,
                                              address: str,
                                              city: str,
                                              country: str) -> str:
        query = f'{address}, {city}, {country}'
        results = self.geocoder.geocode(query)
        if not results:
            return "UNKNOWN"
        return results[0]["annotations"]["geohash"][:self.geohash_precision]

    def get_geohash_from_lat_lon(self,
                                 latitude: float,
                                 longitude: float):
        results = self.geocoder.reverse_geocode(latitude, longitude)
        if not results:
            return "UNKNOWN"
        return results[0]["annotations"]["geohash"][:self.geohash_precision]     