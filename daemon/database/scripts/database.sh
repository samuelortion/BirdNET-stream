#! /usr/bin/env bash
# SQLite library to deal with BirdNET-stream database

set -e

source ./config/analyzer.conf

# Create database in case it was not created yet
./daemon/database/scripts/create.sh

DATABASE=${DATABASE:-"./var/db.sqlite"}

get_location_id() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "SELECT location_id FROM location WHERE latitude=$1 AND longitude=$2"
}

get_taxon_id() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "SELECT taxon_id FROM taxon WHERE scientific_name='$1'"
}

insert_taxon() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "INSERT INTO taxon (scientific_name, common_name) VALUES (\"$1\", \"$2\")"
}

insert_location() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "INSERT INTO location (latitude, longitude) VALUES ($1, $2)"
}

insert_observation() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "INSERT INTO observation (audio_file, start, end, taxon_id, location_id, confidence, date) VALUES ('$1', '$2', '$3', '$4', '$5', '$6', '$7')"
}

# Check if the observation already exists in the database
observation_exists() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "SELECT EXISTS(SELECT observation_id FROM observation WHERE audio_file='$1' AND start='$2' AND end='$3' AND taxon_id='$4' AND location_id='$5')"
}