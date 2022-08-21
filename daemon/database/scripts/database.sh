#! /usr/bin/env bash
# SQLite library to deal with BirdNET-stream observations database

set -e

source ./config/birdnet.conf

# Create database in case it was not created yet
./daemon/database/scripts/create.sh

DATABASE=${DATABASE:-"./var/db.sqlite"}

query() {
    sqlite3 -cmd ".timeout 1000" $DATABASE "$1"
}

get_location_id() {
    query "SELECT location_id FROM location WHERE latitude=$1 AND longitude=$2"
}

get_taxon_id() {
    query "SELECT taxon_id FROM taxon WHERE scientific_name='$1'"
}

insert_taxon() {
    query "INSERT INTO taxon (scientific_name, common_name) VALUES (\"$1\", \"$2\")"
}

insert_location() {
    query "INSERT INTO location (latitude, longitude) VALUES ($1, $2)"
}

insert_observation() {
    query "INSERT INTO observation (audio_file, start, end, taxon_id, location_id, confidence, date) VALUES ('$1', '$2', '$3', '$4', '$5', '$6', '$7')"
}

# Check if the observation already exists in the database
observation_exists() {
    query "SELECT EXISTS(SELECT observation_id FROM observation WHERE audio_file='$1' AND start='$2' AND end='$3' AND taxon_id='$4' AND location_id='$5')"
}