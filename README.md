# bioinformatics-docker Image

## Overview

This project was created as part of a technical assignment to build a Docker image with bioinformatics tools and libraries. The image provides an environment for working with NGS data and based on Ubuntu 22.04. All specialized tools and libraries are built from source using fixed release versions.

## Installed Software

| Software | Version | Description |
|---|---|---|
| [libdeflate](https://github.com/ebiggers/libdeflate) | 1.26 | Fast compression and decompression library |
| [HTSlib](https://github.com/samtools/htslib) | 1.25 | Library for reading and writing sequencing data formats |
| [samtools](https://github.com/samtools/samtools) | 1.25 | Tools for working with SAM, BAM, and CRAM files |
| [bcftools](https://github.com/samtools/bcftools) | 1.25 | Tools for processing VCF and BCF files |
| [VCFtools](https://github.com/vcftools/vcftools) | 0.1.17 | Tools for filtering and analyzing VCF files |

The image also includes utilities such as `bgzip`, `tabix`, `vcf-sort`, and `vcf-validator`.

## Repository Structure

The repository contains two main files:

```text
bioinformatics-docker/
├── Dockerfile
└── README.md
```

- **`Dockerfile`** contains the instructions for installing dependencies, building the bioinformatics tools, and setting up the environment.
- **`README.md`** describes the image and explains how to build, run, and test it.

## Getting Started


Before you start, make sure you have [Docker](https://docs.docker.com/engine/install/) and [Git](https://git-scm.com/downloads) installed to clone the repository.


### Clone the Repository

Clone the repository from GitHub:

```bash
git clone https://github.com/kamankam/bioinformatics-docker.git
cd bioinformatics-docker
```

### Build the Image

Build the Docker image from the project directory:

```bash
docker build -t bioinformatics-tools .
```

This command creates an image named `bioinformatics-tools` using the `Dockerfile` in the current directory.

During the build, Docker installs the required system packages, downloads the specified versions of the bioinformatics tools, and compiles them from source. Each tool is installed in its own directory under `/soft`. Compilation uses `$(nproc)` to run parallel build jobs based on the available CPU cores.


Once the build is complete, check that the image was created:

```bash
docker image ls bioinformatics-tools
```

### Run the Container

Start the container in interactive mode:

```bash
docker run --rm -it bioinformatics-tools bash
```

Here:

- `-it` opens an interactive terminal inside the container.
- `--rm` automatically removes the container when you exit.
- `bash` starts a Bash shell.

Once inside the container, you can run the installed tools directly:

```bash
samtools --help
bcftools --version
vcftools --version
```

To leave the container, type:

```bash
exit
```

The container will be removed, but the Docker image will remain available for future use.

### Work with Local Files

To work with files stored on your computer, you can mount a local directory inside the container.

For example, to mount your current directory as `/data`:

```bash
docker run --rm -it -v "$(pwd):/data" bioinformatics-tools bash
```

Your files will then be available inside the container under `/data`. Files created or modified in `/data` will be saved on your computer and will remain available after the container exits.

## Installation Paths and Environment Variables

All tools and libraries are installed in separate versioned directories under `/soft`:

```text
/soft/
├── libdeflate-1.26/
├── htslib-1.25/
├── samtools-1.25/
├── bcftools-1.25/
└── vcftools-0.1.17/
```

The Dockerfile sets several environment variables to make the installed tools and their dependencies available:

- **`PATH`** includes the directories containing the installed executables. This allows you to run `samtools`, `bcftools`, `vcftools`, and other utilities without typing their full paths.
- **`LD_LIBRARY_PATH`** includes the directories containing the HTSlib and libdeflate shared libraries. This makes the installed library versions available to programs at runtime.
- **`PERL5LIB`** points to the Perl modules installed with VCFtools. Some VCFtools utilities, including `vcf-sort` and `vcf-validator`, need this path to find the `Vcf.pm` module.

The Dockerfile also defines variables containing the full paths to the main executables, such as `SAMTOOLS`, `BCFTOOLS`, and `VCFTOOLS`.

## Verify Installation

After starting the container, you can check that the tools were installed correctly.

### Check Software Versions

Run:

```bash
samtools --help
samtools --version
bcftools --version
vcftools --version
bgzip --version
tabix --version
libdeflate-gzip -V
```

The expected versions are:

| Software | Version |
|---|---|
| samtools | 1.25 |
| bcftools | 1.25 |
| VCFtools | 0.1.17 |
| HTSlib | 1.25 |
| libdeflate | 1.26 |

Both samtools and bcftools should report that they use HTSlib 1.25.

You can also run the main programs using their full paths stored in environment variables:

```bash
"$SAMTOOLS" --version
"$BCFTOOLS" --version
"$VCFTOOLS" --version
```

### Check Shared Libraries

To check which shared libraries are used by samtools and bcftools, run:

```bash
ldd "$SAMTOOLS" | grep -E 'libhts|libdeflate|not found'
ldd "$BCFTOOLS" | grep -E 'libhts|libdeflate|not found'
```

HTSlib and libdeflate should be loaded from their respective directories under `/soft`, with no missing library dependencies.
