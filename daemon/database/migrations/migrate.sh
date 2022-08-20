#! /usr/bin/bash

DEBUG=${DEBUG:-1}
debug() {
    if [ "$DEBUG" -eq 1 ]; then
        echo "$1"
    fi
}

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

if [[ ! -f "$DATABASE" ]]; then
    echo "Database file not found: $DATABASE"
    exit 1
fi

source ./daemon/database/scripts/database.sh

sqlite3 "$DATABASE" "ALTER TABLE observation ADD COLUMN verified BOOLEAN CHECK (verified IN (0, 1)) DEFAULT 0;"