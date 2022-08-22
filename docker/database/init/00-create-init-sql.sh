#! /usr/bin/bash

if [[ -z "${MYSQL_USER}" ]]; then
    MYSQL_USER="birdnet"
    echo "Defaults MYSQL_USER to $MYSQL_USER"
fi
if [[ -z "${MYSQL_USER_PASSWORD}" ]]; then
    echo "MYSQL_ROOT_PASSWORD is not set"
    exit 1
fi
sed -i "s/<MYSQL_USER>/$MYSQL_USER/g" ./01-databases.sql.template ./01-databases.sql
sed -i "s/<MYSQL_USER_PASSWORD>/$MYSQL_USER_PASSWORD/g" ./01-databases.sql.template ./01-databases.sql