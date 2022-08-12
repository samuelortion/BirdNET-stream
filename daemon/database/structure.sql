/** Database structure for BirdNET-stream SQLite*/

/** Taxon table */
CREATE TABLE IF NOT EXISTS taxon (
    taxon_id INTEGER PRIMARY KEY,
    scientific_name TEXT NOT NULL,
    common_name TEXT NOT NULL
);

/** Locality table */
CREATE TABLE IF NOT EXISTS locality (
    locality_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL
);

/** Observation table */
CREATE TABLE IF NOT EXISTS observation (
    observation_id INTEGER PRIMARY KEY,
    taxon_id INTEGER NOT NULL,
    locality_id INTEGER NOT NULL,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    notes TEXT,
    confidence REAL NOT NULL,
    FOREIGN KEY(taxon_id) REFERENCES taxon(taxon_id),
    FOREIGN KEY(locality_id) REFERENCES locality(locality_id)
);