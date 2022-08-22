# All in One BirdNET docker image
FROM debian:bullseye

ENV REPOSITORY=${REPOSITORY:-https://github.com/UncleSamulus/BirdNET-stream.git}
# DEBUG defaults to 1 for descriptive DEBUG logs, 0 for error logs only 
ENV DEBUG=${DEBUG:-1} 
WORKDIR /home/birdnet
RUN useradd -m -s /bin/bash -G sudo birdnet
USER birdnet

# Upgrade system
RUN apt-get update && apt-get upgrade -y

# Install some dependencies
RUN apt-get install -y \
    sudo \
    git \
    curl \
    bash \
    vim \
    systemctl

COPY ./install.sh install.sh

RUN ./install.sh

EXPOSE 443