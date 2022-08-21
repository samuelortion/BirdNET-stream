#! /usr/bin/env bash

# Load config file
config_filepath="./config/birdnet.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

# Check if database location is specified
if [ -z "$DATABASE" ]; then
    echo "DATABASE location not specified"
    echo "Defaults to ./var/db.sqlite"
    DATABASE="./var/db.sqlite"
fi

function insert_observation() 
{
    # Insert observation into database
    template=$(cat ./daemon/database/observation_template.sql)
    statement=$(echo "$template" | sed "s/:taxon_id/$1/g" | sed "s/:location_id/$2/g" | sed "s/:date/$3/g" | sed "s/:time/$4/g" | sed "s/:confidence/$5/g" | sed "s/:notes/$6/g")
    result=$(sqlite3 "$DATABASE" $statement)
    echo "$result"
}

function get_taxon_id()
{
    # Get taxon id from database
    statement="SELECT taxon_id FROM taxon WHERE scientific_name='$1'"
    result=$(sqlite3 "$DATABASE" "$statement")
    echo "$result"
}

function test() 
{
    taxon_scientific_name="Erithacus rubecula"
    taxon_id=$(get_taxon_id "$taxon_scientific_name")
}