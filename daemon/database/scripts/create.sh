#! /usr/bin/env bash

# Load config file
config_filepath="./config/analyzer.conf"

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

# Create database according to schema in structure.sql
sqlite3 "$DATABASE" < ./daemon/database/structure.sql