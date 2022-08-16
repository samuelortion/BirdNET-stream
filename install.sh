#! /usr/bin/env bash
# set -x
set -e

DEBUG=${DEBUG:-0}

# Standard Installation Script for BirdNET-stream for Debian Based Linux distros

REQUIREMENTS="git ffmpeg python3-pip python3-dev"
REPOSITORY="https://github.com/UncleSamulus/BirdNET-stream.git"

# Update system
update() {
    sudo apt-get update
    sudo apt-get upgrade -y
}

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo "$1"
    fi
}

install_requirements() {
    requirements=$1
    # Install requirements
    missing_requirements=""
    for requirement in $requirements; do
        if ! dpkg -s $requirement >/dev/null 2>&1; then
            missing_requirements="$missing_requirements $requirement"
        fi
    done
    if [ -n "$missing_requirements" ]; then
        debug "Installing missing requirements: $missing_requirements"
        sudo apt-get install $missing_requirements
    fi
}

# Install BirdNET-stream
install_birdnetstream() {
    # Check if repo is not already installed
    workdir=$(pwd)
    if [ -d "$workdir/BirdNET-stream" ]; then
        debug "BirdNET-stream is already installed"
    else
        # Clone BirdNET-stream
        debug "Cloning BirdNET-stream from $REPOSITORY"
        git clone --recurse-submodules $REPOSITORY
        # Install BirdNET-stream
    fi
    cd BirdNET-stream
    debug "Creating python3 virtual environment '$PYTHON_VENV'"
    python3 -m venv $PYTHON_VENV
    debug "Activating $PYTHON_VENV"
    source .venv/birdnet-stream/bin/activate
    debug "Installing python packages"
    pip install -U pip
    pip install -r requirements.txt
}

# Install systemd services
install_birdnetstream_services() {
    cd BirdNET-stream
    DIR=$(pwd)
    GROUP=$USER
    debug "Setting up BirdNET stream systemd services"
    services="birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer birdnet_miner.service birdnet_plotter.service birdnet_plotter.timer"
    read -r -a services_array <<<"$services"

    for service in ${services_array[@]}; do
        sudo cp daemon/systemd/templates/$service /etc/systemd/system/
        variables="DIR USER GROUP"
        for variable in $variables; do
            sudo sed -i "s|<$variable>|${!variable}|g" /etc/systemd/system/$service
        done
    done
    sudo systemctl daemon-reload
    sudo systemctl enable --now birdnet_recording.service birdnet_analyzis.service birdnet_miner.timer birdnet_plotter.timer
}

install_php8() {
    # Remove previously installed php version
    sudo apt-get remove --purge php*
    # Install required packages for php
    sudo apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
    # Get php package from sury repo
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
    sudo wget -qO - https://packages.sury.org/php/apt.gpg | sudo gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/debian-php-8.gpg --import
    sudo chmod 644 /etc/apt/trusted.gpg.d/debian-php-8.gpg
    update
    sudo apt-get install php8.1
    # Install and enable php-fpm
    sudo apt-get install php8.1-fpm
    sudo systemctl enable php8.1-fpm
    # Install php packages
    sudo apt-get install php8.1-{sqlite3,curl,intl}
}

install_composer() {
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"\nphp -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"\nphp composer-setup.php\nphp -r "unlink('composer-setup.php');"
    sudo mv /composer.phar /usr/local/bin/composer
}

install_nodejs() {
    # Install nodejs
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    nvm install 16
    nvm use 16
    install_requirements "npm"
    # Install yarn
    sudo npm install -g yarn
}

install_web_interface() {
    debug "Setting up web interface"
    install_requirements "nginx"
    # Install php 8.1
    install_php8
    # Install composer
    install_composer
    # Install nodejs 16
    install_nodejs
    # Install Symfony web app
    cd BirdNET-stream
    cd www
    debug "Creating nginx configuration"
    cp nginx.conf /etc/nginx/sites-available/birdnet-stream.conf
    sudo mkdir /var/log/nginx/birdnet/
    echo "Info: Please edit /etc/nginx/sites-available/birdnet-stream.conf to set the correct server name and paths"
    sudo ln -s /etc/nginx/sites-available/birdnet-stream.conf /etc/nginx/sites-enabled/birdnet-stream.conf
    sudo systemctl enable --now nginx
    sudo systemctl restart nginx
    debug "Retrieving composer dependencies"
    composer install
    debug "Installing nodejs dependencies"
    yarn install
    debug "Building assets"
    yarn build
    debug "Web interface is available"
    debug "Please restart nginx after double check of /etc/nginx/sites-available/birdnet-stream.conf"
}

main() {
    update
    install_requirements $REQUIREMENTS
    install_birdnetstream
    install_birdnetstream_services
    install_web_interface
}

main
