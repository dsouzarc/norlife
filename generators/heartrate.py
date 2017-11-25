"""heartrate.py: Responsible for quickly generating random heartrate data"""

from datetime import datetime
from datetime import timedelta

import json
import random

from bson import json_util
from pymongo import MongoClient

import numpy
import pymongo


user_id = '6e9c0f4d-4ec4-478a-95c9-cdfd97198f8d'
mongo_address = 'mongodb://138.197.36.15:27017'
database_client = MongoClient(mongo_address)
database = database_client['norlife']

heartrate_table = database['heartrate']

date_iterator = datetime(2017, 11, 25, 21, 00, 00)
end_date = datetime(2016, 11, 25, 21, 00, 00)

day_difference = (date_iterator - end_date).days

heartbeats = numpy.random.normal(60, 15, day_difference ** 2)

counter = 0

heartbeat_data_for_insert = list()

for i in range(0, day_difference):
    for y in range(0, 2):

        heartbeat = heartbeats[counter]

        #Get rid of invalid heartbeats
        while heartbeat < 40:
            counter += 1
            heartbeat = heartbeats[counter]

        heartbeat_data = { 
                'heartbeat': int(heartbeat),
                'user_id': user_id,
                'date_recorded': date_iterator
        }
        heartbeat_data_for_insert.append(heartbeat_data)

        date_iterator = date_iterator - timedelta(hours=12)
        counter += 1
        

heartrate_table.insert_many(heartbeat_data_for_insert)
