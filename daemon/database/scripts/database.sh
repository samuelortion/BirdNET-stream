#! /usr/bin/env bash
# SQLite library to deal with BirdNET-stream observations database

set -e

source ./config/birdnet.conf

# Create database in case it was not created yet
./daemon/database/scripts/create.sh

# Check if database location is specified
if [ -z "$DATABASE" ]; then
    echo "DATABASE location not specified"
    echo "Defaults to ./var/db.sqlite"
    DATABASE="./var/db.sqlite"
fi

query() {
    local stmt
    stmt="$1"
    if [[ $DATABASE = "mysql://"* ]]; then
        # Split mysql uri into user, password, host, port, and database
        MYSQL_ADDRESS=$(echo "$DATABASE" | sed 's/mysql:\/\///g')
        MYSQL_CREDENTIALS=$(echo "$MYSQL_ADDRESS" | cut -d@ -f1)
        MYSQL_USER=$(echo "$MYSQL_CREDENTIALS" | cut -d: -f1)
        MYSQL_PASSWORD=$(echo "$MYSQL_CREDENTIALS" | cut -d: -f2)
        MYSQL_HOST=$(echo "$MYSQL_ADDRESS" | cut -d@ -f2 | cut -d: -f1)
        MYSQL_PORT=$(echo "$MYSQL_ADDRESS" | cut -d@ -f2 | cut -d: -f2 | cut -d/ -f1)
        MYSQL_DATABASE=$(echo "$MYSQL_ADDRESS" | cut -d/ -f2)
        mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT -D$MYSQL_DATABASE -e "$stmt"
    else
        sqlite3 -cmd ".timeout 1000" "$DATABASE" "$stmt"
    fi

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
