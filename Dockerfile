FROM ubuntu:22.04

ENV SOFT=/soft

WORKDIR ${SOFT}

# Install system dependencies
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
        perl \
	python3 \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*


# Install pysam.v0.24.1
RUN python3 -m pip install --no-cache-dir "pysam==0.24.1"

# Install libdeflate.v1.26
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


# Install HTSlib.v1.25
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


# Install samtools.v1.25
RUN curl -fL https://github.com/samtools/samtools/releases/download/1.25/samtools-1.25.tar.bz2 \
        -o /tmp/samtools-1.25.tar.bz2 && \
    tar -xjf /tmp/samtools-1.25.tar.bz2 -C /tmp && \
    cd /tmp/samtools-1.25 && \
    ./configure \
        --prefix="${SOFT}/samtools-1.25" \
        --with-htslib="${SOFT}/htslib-1.25" \
        LDFLAGS="-L${SOFT}/htslib-1.25/lib -Wl,-rpath,${SOFT}/htslib-1.25/lib" && \
    make -j"$(nproc)" && \
    make install && \
    cd / && \
    rm -rf /tmp/samtools-1.25 /tmp/samtools-1.25.tar.bz2


# Install bcftools.v1.25
RUN curl -fL https://github.com/samtools/bcftools/releases/download/1.25/bcftools-1.25.tar.bz2 \
        -o /tmp/bcftools-1.25.tar.bz2 && \
    tar -xjf /tmp/bcftools-1.25.tar.bz2 -C /tmp && \
    cd /tmp/bcftools-1.25 && \
    ./configure \
        --prefix="${SOFT}/bcftools-1.25" \
        --with-htslib="${SOFT}/htslib-1.25" \
        LDFLAGS="-L${SOFT}/htslib-1.25/lib -Wl,-rpath,${SOFT}/htslib-1.25/lib" && \
    make -j"$(nproc)" && \
    make install && \
    cd / && \
    rm -rf /tmp/bcftools-1.25 /tmp/bcftools-1.25.tar.bz2


# Install VCFtools.v0.1.17
RUN curl -fL https://github.com/vcftools/vcftools/releases/download/v0.1.17/vcftools-0.1.17.tar.gz \
        -o /tmp/vcftools-0.1.17.tar.gz && \
    tar -xzf /tmp/vcftools-0.1.17.tar.gz -C /tmp && \
    cd /tmp/vcftools-0.1.17 && \
    ./configure --prefix="${SOFT}/vcftools-0.1.17" && \
    make -j"$(nproc)" && \
    make install && \
    cd / && \
    rm -rf /tmp/vcftools-0.1.17 /tmp/vcftools-0.1.17.tar.gz



# Set executable directories in PATH
ENV PATH="${SOFT}/libdeflate-1.26/bin:${SOFT}/htslib-1.25/bin:${SOFT}/samtools-1.25/bin:${SOFT}/bcftools-1.25/bin:${SOFT}/vcftools-0.1.17/bin:${PATH}"

# Set library path
ENV LD_LIBRARY_PATH="${SOFT}/libdeflate-1.26/lib:${SOFT}/htslib-1.25/lib"
# Set Perl modules path
ENV PERL5LIB="${SOFT}/vcftools-0.1.17/share/perl/5.34.0"

# Set program paths
ENV BGZIP="${SOFT}/htslib-1.25/bin/bgzip" \
    TABIX="${SOFT}/htslib-1.25/bin/tabix" \
    HTSFILE="${SOFT}/htslib-1.25/bin/htsfile" \
    LIBDEFLATEGZIP="${SOFT}/libdeflate-1.26/bin/libdeflate-gzip" \
    LIBDEFLATEGUNZIP="${SOFT}/libdeflate-1.26/bin/libdeflate-gunzip" \
    SAMTOOLS="${SOFT}/samtools-1.25/bin/samtools" \
    BCFTOOLS="${SOFT}/bcftools-1.25/bin/bcftools" \
    VCFTOOLS="${SOFT}/vcftools-0.1.17/bin/vcftools"

# Copy SNP processing scripts
COPY fp-snps/scripts/ /soft/fp-snps/scripts/
