# Recording container for BirdNET-stream
# Reference: https://leimao.github.io/blog/Docker-Container-Audio/

FROM debian:bullseye

ENV DEBIAN_FRONTEND noninteractive

# Install packages dependencies

RUN apt-get update && \
    apt-get install apt-utils \
    && apt-get install -y --no-install-recommends \
    libasound2 \
    alsa-utils \
    libsndfile1-dev \
    && apt-get clean
