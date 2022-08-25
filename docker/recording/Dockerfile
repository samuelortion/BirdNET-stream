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
    ffmpeg \
    && apt-get clean

WORKDIR /opt/birdnet

ENTRYPOINT ["./daemon/birdnet_recording.sh"]