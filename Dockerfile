FROM ubuntu:22.04

ENV SOFT=/soft

WORKDIR /soft

# Install tools and libraries required for building bioinformatics software
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        pkg-config \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libncurses-dev \
        curl \
        ca-certificates \
        perl && \
    rm -rf /var/lib/apt/lists/*
