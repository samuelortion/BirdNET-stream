# Recording container for BirdNET-stream
# References:
# - https://leimao.github.io/blog/Docker-Container-Audio/
# - https://askubuntu.com/questions/972510/how-to-set-alsa-default-device-to-pulseaudio-sound-server-on-docker

FROM debian:bullseye

ENV DEBIAN_FRONTEND noninteractive

# Install packages dependencies
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
    --no-install-recommends \
    libasound2 \
    alsa-utils \
    libsndfile1-dev \
    && apt-get install -y ffmpeg \
    && apt-get clean

RUN mkdir -p /opt/birdnet/
WORKDIR /opt/birdnet/
COPY config ./config
COPY daemon/birdnet_recording.sh /usr/local/bin/birdnet_recording.sh

ENTRYPOINT ["/usr/local/bin/birdnet_recording.sh"]