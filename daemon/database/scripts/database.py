#! /usr/bin/env python3

import sqlite3
import os

verbose = False

"""Load config"""
def load_conf():
    with open("./config/birdnet.conf", "r") as f:
        conf = f.readlines()
        res = dict(map(str.strip, sub.split('=', 1)) for sub in conf if '=' in sub)
    return res

# Singleton database instance
database = None
def get_database():
    global database
    if database is None:
        database = sqlite3.connect(CONFIG["DATABASE"])
    return database
    
"""Create the database if it doesn't exist"""
def create_database():
    # Create the database
    database =

    database = get_database()
    cursor = database.cursor()
    with open("./daemon/database/structure.sql", "r") as f:
        cursor.executescript(f.read())
    database.commit()

"""Insert an observation into the database"""
def insert_observation(observation):
    database = get_database()
    cursor = database.cursor()
    cursor.execute(f"INSERT INTO observation (taxon_id, locality_id, date, time, confidence) VALUES ({observation['taxon_id']}, {observation['locality_id']}, {observation['date']}, {observation['time']}, {observation['confidence']});")
    database.commit()

"""Insert a taxon in database"""
def insert_taxon(taxon):
    database = get_database()
    cursor = database.cursor()
    cursor.execute(f"INSERT INTO taxon (scientific_name, common_name) VALUES ('{taxon['scientific_name']}', '{taxon['common_name']}');")
    database.commit()

"""Insert a location into database"""
def insert_locality(locality):
    database = get_database()
    cursor = database.cursor()
    cursor.execute(f"INSERT INTO locality (name, latitude, longitude) VALUES ('{locality['name']}', {locality['latitude']}, {locality['longitude']});")
    database.commit()

"""Insert all species from list into database"""
def insert_all_species(species):
    database = get_database()
    cursor = database.cursor()
    for sp in species:
        # Check if the species already exists in the database
        cursor.execute(f"SELECT * FROM taxon WHERE scientific_name = '{sp[0]}';")
        # If it doesn't exist, insert it
        if cursor.fetchone() is None:
            cursor.execute(f"INSERT INTO taxon (scientific_name, common_name) VALUES ('{sp[0]}', '{sp[1]}');")
            database.commit()

CONFIG = load_conf()

def main():
    # Create the database if it doesn't exist
    if not os.path.exists(CONFIG["DATABASE"]):
        create_database()
    else:
        print("Database already exists")
    
    # Open species list file
    with open(CONFIG["SPECIES_LIST"], "r") as f:
        species = f.readlines()
    species = [sp.split("_") for sp in species]
    
if __name__ == "__main__":
    main()
    database.close()