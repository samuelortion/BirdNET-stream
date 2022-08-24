/** Database structure for BirdNET-stream SQLite*/

/** Taxon table */
CREATE TABLE IF NOT EXISTS taxon (
    taxon_id INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
    scientific_name TEXT NOT NULL,
    common_name TEXT NOT NULL
);

/** Location table */
CREATE TABLE IF NOT EXISTS location (
    location_id INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL
);

/** Observation table */
CREATE TABLE IF NOT EXISTS observation (
    `observation_id` INTEGER PRIMARY KEY NOT NULL AUTO_INCREMENT,
    `audio_file` TEXT NOT NULL,
    `start` REAL NOT NULL,
    `end` REAL NOT NULL,
    `taxon_id` INTEGER NOT NULL,
    `location_id` INTEGER NOT NULL,
    `date` TEXT NOT NULL,
    `notes` TEXT,
    `confidence` REAL NOT NULL,
    `verified` BOOLEAN DEFAULT 0 CHECK (`verified` IN (0, 1)),
    FOREIGN KEY(taxon_id) REFERENCES taxon(taxon_id),
    FOREIGN KEY(location_id) REFERENCES location(location_id)
);
