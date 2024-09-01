# Base image with:
# - Ubuntu 22.04
# - Python 3.10.12
# - GDAL 3.7.3, released 2023/10/30
FROM ghcr.io/osgeo/gdal:ubuntu-small-3.7.3

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    PATH="/root/.cargo/bin:${PATH}

# Apt installation
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      # python3-pip \
      curl \
      libpq-dev \
    && apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}

# Install uv, compile and install requirements, and install dea-intertidal
WORKDIR /app
# COPY requirements.in .
COPY . .

# Install uv using curl
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# RUN pip install uv && \
RUN uv pip compile requirements.in -o requirements.txt && \
    uv pip install -r requirements.txt --system && \
    uv pip install awscli==1.33.37 --system && \
    uv pip install . --system && \
    uv pip check && \
    dea-intertidal --help

# Set the entrypoint to dea-intertidal
ENTRYPOINT ["dea-intertidal"]
