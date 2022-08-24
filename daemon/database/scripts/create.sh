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

if [[ $DATABASE = "mysql://"* ]]; then
    # Split mysql uri into user, password, host, port, and database
    MYSQL_ADDRESS=$(echo "$DATABASE" | sed 's/mysql:\/\///g')
    MYSQL_CREDENTIALS=$(echo "$MYSQL_ADDRESS" | cut -d@ -f1)
    MYSQL_USER=$(echo "$MYSQL_CREDENTIALS" | cut -d: -f1)
    MYSQL_PASSWORD=$(echo "$MYSQL_CREDENTIALS" | cut -d: -f2)
    MYSQL_HOST=$(echo "$MYSQL_ADDRESS" | cut -d@ -f2 | cut -d: -f1)
    MYSQL_PORT=$(echo "$MYSQL_ADDRESS" | cut -d@ -f2 | cut -d: -f2 | cut -d/ -f1)
    MYSQL_DATABASE=$(echo "$MYSQL_ADDRESS" | cut -d/ -f2)
    mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST -P$MYSQL_PORT -D$MYSQL_DATABASE < ./daemon/database/structure-mysql.sql
else
    sqlite3 $DATABASE < ./daemon/database/structure-sqlite.sql
fi
