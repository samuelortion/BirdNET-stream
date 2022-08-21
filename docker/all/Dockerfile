# All in One BirdNET docker image
FROM debian:bullseye

ENV REPOSITORY=${REPOSITORY:-https://github.com/UncleSamulus/BirdNET-stream.git}
# DEBUG defaults to 1 for descriptive DEBUG logs, 0 for error logs only 
ENV DEBUG=${DEBUG:-1} 
RUN useradd birdnet
WORKDIR /home/birdnet

# Upgrade system
RUN apt-get update && apt-get upgrade -y

# Install sudo
RUN apt-get install -y \
    sudo \
    git

COPY ./install.sh install.sh

RUN bash ./install.sh

USER birdnet
