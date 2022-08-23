#! /usr/bin/env bash
# Standard Installation Script for BirdNET-stream for Debian Based Linux distros
# set -x
set -e

DEBUG=${DEBUG:-0}

REQUIREMENTS="git wget ffmpeg python3 python3-pip python3-dev python3-venv zip unzip sqlite3"
REPOSITORY=${REPOSITORY:-https://github.com/UncleSamulus/BirdNET-stream.git}
BRANCH=${BRANCH:-main}
WORKDIR="$(pwd)/BirdNET-stream"
PYTHON_VENV="./.venv/birdnet-stream"

debug() {
    [[ $DEBUG -eq 1 ]] && echo "$@"
}

add_birdnet_user() {
    sudo useradd -m -s /bin/bash -G sudo birdnet
    sudo usermod -aG birdnet $USER
    sudo usermod -aG birdnet www-data
}

install_requirements() {
    requirements=$1
    # Install requirements
    missing_requirements=""
    for requirement in $requirements; do
        if ! dpkg -s "$requirement" >/dev/null 2>&1; then
            missing_requirements="$missing_requirements $requirement"
        fi
    done
    if [[ -n "$missing_requirements" ]]; then
        debug "Installing missing requirements: $missing_requirements"
        sudo apt-get install -y $missing_requirements
    fi
}

# Install BirdNET-stream
install_birdnetstream() {
    # Check if repo is not already installed
    if [[ -d "$WORKDIR" ]]; then
        debug "BirdNET-stream is already installed, use update script (not implemented yet)"
    else
        debug "Installing BirdNET-stream"
        debug "Creating BirdNET-stream directory"
        mkdir -p "$WORKDIR"
        # Clone BirdNET-stream
        cd "$WORKDIR"
        debug "Cloning BirdNET-stream from $REPOSITORY"
        git clone -b "$BRANCH"--recurse-submodules "$REPOSITORY" .
        debug "Creating python3 virtual environment $PYTHON_VENV"
        python3 -m venv $PYTHON_VENV
        debug "Activating $PYTHON_VENV"
        source "$PYTHON_VENV/bin/activate"
        debug "Installing python packages"
        pip3 install -U pip
        pip3 install -r requirements.txt
        debug "Creating ./var directory"
        mkdir -p ./var/{charts,chunks/{in,out}}
    fi
}

# Install systemd services
install_birdnetstream_services() {
    GROUP=birdnet
    DIR="$WORKDIR"
    cd "$WORKDIR"
    debug "Setting up BirdNET stream systemd services"
    services="birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer birdnet_miner.service birdnet_plotter.service birdnet_plotter.timer"
    read -r -a services_array <<<"$services"
    for service in ${services_array[@]}; do
        sudo cp "daemon/systemd/templates/$service" "/etc/systemd/system/"
        variables="DIR USER GROUP"
        for variable in $variables; do
            sudo sed -i "s|<$variable>|${!variable}|g" "/etc/systemd/system/$service"
        done
    done
    sudo sed -i "s|<VENV>|$WORKDIR/$PYTHON_VENV|g" "/etc/systemd/system/birdnet_plotter.service"
    sudo systemctl daemon-reload
    enabled_services="birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer birdnet_plotter.timer"
    read -r -a services_array <<<"$services"
    for service in ${services_array[@]}; do
        debug "Enabling $service"
        sudo systemctl enable "$service"
        sudo systemctl start "$service"
    done
}

install_php8() {
    # Remove previously installed php version
    sudo apt-get remove --purge php* -y
    # Install required packages for php
    sudo apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
    # Get php package from sury repo
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
    sudo wget -qO - https://packages.sury.org/php/apt.gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-php-8.gpg --import
    sudo chmod 644 /etc/apt/trusted.gpg.d/debian-php-8.gpg
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y php8.1
    # Install and enable php-fpm
    sudo apt-get install -y php8.1-fpm
    sudo systemctl enable --now php8.1-fpm
    # Install php packages
    sudo apt-get install -y php8.1-{sqlite3,curl,intl,xml,zip}
}

install_composer() {
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
}

install_nodejs() {
    # Install nodejs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$([[ -z "${XDG_CONFIG_HOME-}" ]] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install 16
    nvm use 16
    install_requirements "npm"
    # Install yarn
    sudo npm install -g yarn
}

install_web_interface() {
    debug "Setting up web interface"
    # Install php 8.1
    install_php8
    # Install composer
    install_composer
    # Install nodejs 16
    install_nodejs
    # Install Symfony web app
    cd "$WORKDIR"
    cd www
    debug "Retrieving composer dependencies"
    composer install
    debug "PHP dependencies installed"
    debug "Installing nodejs dependencies"
    yarn install
    debug "npm dependencies installed"
    debug "Building assets"
    yarn build
    debug "Webpack assets built"
    debug "Web interface is available"
    debug "Please restart nginx after double check of /etc/nginx/sites-available/birdnet-stream.conf"
}

setup_http_server() {
    debug "Setting up HTTP server"
    install_requirements "nginx"
    debug "Setup nginx server"
    cd "$WORKDIR"
    cd www
    debug "Creating nginx configuration"
    sudo cp nginx.conf.template /etc/nginx/sites-available/birdnet-stream.conf
    sudo mkdir -p /var/log/nginx/birdnet/
    if [[ -f "/etc/nginx/sites-enabled/birdnet-stream.conf" ]]; then
        sudo unlink /etc/nginx/sites-enabled/birdnet-stream.conf
    fi
    debug "Enable birdnet.lan domain"
    sudo ln -s /etc/nginx/sites-available/birdnet-stream.conf /etc/nginx/sites-enabled/birdnet-stream.conf
    debug "Info: Please edit /etc/nginx/sites-available/birdnet-stream.conf to set the correct server name and paths"
    debug "Setup nginx variables the best way possible"
    sudo sed -i "s|<SYMFONY_PUBLIC>|$WORKDIR/www/public/|g" /etc/nginx/sites-available/birdnet-stream.conf
    sudo sed -i "s|<RECORDS_FOLDER>|$CHUNK_FOLDER/out|g" /etc/nginx/sites-available/birdnet-stream.conf
    sudo sed -i "s|<CHARTS_FOLDER>|$WORKDIR/var/charts|g" /etc/nginx/sites-available/birdnet-stream.conf
    debug "Generate self signed certificate"
    CERTS_LOCATION="/etc/nginx/certs/birdnet"
    sudo mkdir -p "$CERTS_LOCATION"
    cd $CERTS_LOCATION
    sudo openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out fullchain.pem -sha256 -days 365 -nodes --subj '/CN=birdnet.lan'
    sudo sed -i "s|<CERTIFICATE>|$CERTS_LOCATION/fullchain.pem|g" /etc/nginx/sites-available/birdnet-stream.conf
    sudo sed -i "s|<PRIVATE_KEY>|$CERTS_LOCATION/privkey.pem|g" /etc/nginx/sites-available/birdnet-stream.conf
    sudo systemctl enable --now nginx
    sudo systemctl restart nginx
    cd -
}

change_value() {
    local variable_name
    variable_name="$1"
    local variable_new_value
    variable_new_value="$2"
    local variable_filepath="$3"
    sed -i "s|$variable_name=.*|$variable_name=\"$variable_new_value\"|g" "$variable_filepath"
}

install_config() {
    debug "Updating config"
    cd "$WORKDIR"
    cp ./config/birdnet.conf.example ./config/birdnet.conf
    config_filepath="$WORKDIR/config/birdnet.conf"
    change_value "DIR" "$WORKDIR" "$config_filepath"
    change_value "PYTHON_VENV" "$PYTHON_VENV" "$config_filepath"
    change_value "AUDIO_RECORDING" "true" "$config_filepath"
    source "$config_filepath"
    cd www
    debug "Setup webapp .env"
    cp .env.local.example .env.local
    change_value "RECORDS_DIR" "$CHUNKS_FOLDER" ".env.local"
}

update_permissions() {
    debug "Updating permissions (may not work properly)"
    cd $WORKDIR
    sudo chown -R $USER:birdnet "$WORKDIR"
    sudo chown -R $USER:birdnet "$CHUNK_FOLDER"
    sudo chmod -R 755 "$CHUNK_FOLDER"
}

main() {
    install_requirements "$REQUIREMENTS"
    install_birdnetstream
    install_birdnetstream_services
    install_web_interface
    setup_http_server
    install_config
    update_permissions
    debug "Installation done"
}

main
