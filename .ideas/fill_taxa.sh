#! /usr/bin/env bash

set -e

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

# Check if species list is specified
if [ -z "$SPECIES_LIST" ]; then
    echo "SPECIES_LIST location not specified"
    exit 1
fi

function insert_taxa()
{
    for taxon in "$(cat $SPECIES_LIST)"; do
        taxon_scientific_name=$(echo $taxon | cut -d'_' -f1) 
        taxon_common_name=$(echo $taxon | cut -d'_' -f2)
        if $(taxon_exists $taxon_scientific_name); then
            echo "Taxon already exists: $taxon_scientific_name"
        else
            echo "Inserting taxon: $taxon_scientific_name"
            statement="INSERT INTO taxon (scientific_name, common_name) VALUES ('$taxon_scientific_name', '$taxon_common_name')"
            echo $statement
            result=$(sqlite3 "$DATABASE" "$statement")
            echo "$result"
        fi
    done
}

function taxon_exists()
{
    taxon_scientific_name="$1"
    statement="SELECT scientific_name FROM taxon WHERE scientific_name='$taxon_scientific_name'"
    result=$(sqlite3 "$DATABASE" "$statement")
    if [ -z "$result" ]; then
        return 1
    else
        return 0
    fi
}

function purge_taxa()
{
    statement="DELETE FROM taxon"
    result=$(sqlite3 "$DATABASE" "$statement")
    echo "$result"
}

function main() 
{
    purge_taxa
    insert_taxa
}

main