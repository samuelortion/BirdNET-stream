#! /usr/bin/env bash
# inspired by https://unix.stackexchange.com/questions/47132/execute-shell-script-from-php-as-root-user
set -e 
# set -x

config_filepath="./config/analyzer.conf"

if [ -f "$config_filepath" ]; then
    source "$config_filepath"
else
    echo "Config file not found: $config_filepath"
    # exit 1
fi

if [[ -z $DAEMON_USER ]]
then
    echo "DAEMON_USER is not set"
    # exit 1
fi

if [[ -z $DAEMON_PASSWORD ]]
then
    echo "DAEMON_PASSWORD is not set"
    # exit 1
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
    if [[ -z $2 ]]; then
        services=$SERVICES
    else
        services=$2
    fi
    debug "$action birdnet services"
    # sshpass -p $DAEMON_PASSWORD sudo -S -u $DAEMON_USER sudo systemctl $action $services
    sudo systemctl $action $services
    echo "done"
}

manage $1 $2