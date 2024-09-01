# Base image with:
# - Ubuntu 22.04
# - Python 3.10.12
# - GDAL 3.7.3, released 2023/10/30
FROM ghcr.io/osgeo/gdal:ubuntu-small-3.7.3

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Apt installation
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      python3-pip \
      libpq-dev \
    && apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

WORKDIR /app

# Install uv
RUN pip install uv && uv --version

# Copy requirements and compile
COPY requirements.in .
RUN uv pip compile requirements.in -o requirements.txt

# Install requirements
RUN uv pip install -r requirements.txt awscli==1.33.37 --system

# Copy the rest of the code
COPY . .

# Install dea-intertidal
RUN uv pip install . --system

# Verify installation
RUN uv pip check
RUN dea-intertidal --help

ENTRYPOINT ["dea-intertidal"]
