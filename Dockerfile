FROM ubuntu:22.04

ENV SOFT=/soft

WORKDIR ${SOFT}

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


# Build and install libdeflate 1.26
RUN curl -fL https://github.com/ebiggers/libdeflate/archive/refs/tags/v1.26.tar.gz \
        -o /tmp/libdeflate-1.26.tar.gz && \
    tar -xzf /tmp/libdeflate-1.26.tar.gz -C /tmp && \
    cmake -S /tmp/libdeflate-1.26 \
        -B /tmp/libdeflate-1.26/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${SOFT}/libdeflate-1.26 && \
    cmake --build /tmp/libdeflate-1.26/build --parallel 2 && \
    cmake --install /tmp/libdeflate-1.26/build && \
    rm -rf /tmp/libdeflate-1.26 /tmp/libdeflate-1.26.tar.gz

