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
    cmake --build /tmp/libdeflate-1.26/build --parallel "$(nproc)" && \
    cmake --install /tmp/libdeflate-1.26/build && \
    rm -rf /tmp/libdeflate-1.26 /tmp/libdeflate-1.26.tar.gz


# Build and install HTSlib 1.25
RUN curl -fL https://github.com/samtools/htslib/releases/download/1.25/htslib-1.25.tar.bz2 \
        -o /tmp/htslib-1.25.tar.bz2 && \
    tar -xjf /tmp/htslib-1.25.tar.bz2 -C /tmp && \
    cd /tmp/htslib-1.25 && \
    ./configure \
        --prefix="${SOFT}/htslib-1.25" \
        --with-libdeflate \
        CPPFLAGS="-I${SOFT}/libdeflate-1.26/include" \
        LDFLAGS="-L${SOFT}/libdeflate-1.26/lib -Wl,-rpath,${SOFT}/libdeflate-1.26/lib" && \
    make -j"$(nproc)" && \
    make install && \
    cd / && \
    rm -rf /tmp/htslib-1.25 /tmp/htslib-1.25.tar.bz2


# Add specialized executable directories to PATH
ENV PATH="${SOFT}/libdeflate-1.26/bin:${SOFT}/htslib-1.25/bin:${PATH}"

# Add specialized shared library directories
ENV LD_LIBRARY_PATH="${SOFT}/libdeflate-1.26/lib:${SOFT}/htslib-1.25/lib"

# Set full paths to installed programs
ENV BGZIP="${SOFT}/htslib-1.25/bin/bgzip" \
    TABIX="${SOFT}/htslib-1.25/bin/tabix" \
    HTSFILE="${SOFT}/htslib-1.25/bin/htsfile" \
    LIBDEFLATEGZIP="${SOFT}/libdeflate-1.26/bin/libdeflate-gzip" \
    LIBDEFLATEGUNZIP="${SOFT}/libdeflate-1.26/bin/libdeflate-gunzip"
