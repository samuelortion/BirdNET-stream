#! /usr/bin/env bash

set -e 
# set -x

config_filepath="./config/analyzer.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    exit 1
fi

if [[ -z $DAEMON_USER ]]
then
    echo "DAEMON_USER is not set"
    exit 1
fi

if [[ -z $DAEMON_PASSWORD ]]
then
    echo "DAEMON_PASSWORD is not set"
    exit 1
fi

SERVICES="$(sudo -S <<< $DAEMON_PASSWORD ls /etc/systemd/system/ | grep 'birdnet')"

DEBUG=${DEBUG:-0}

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

manage() {
    action=$1
    debug "$action birdnet services"
    sudo -S <<< $DAEMON_PASSWORD systemctl $action $SERVICES
    echo "done"
}

stop() {
    manage stop
}

start() {
    manage start
}

manage $1