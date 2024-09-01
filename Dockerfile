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

# Install uv (faster than pip-tools)
RUN pip install uv

# Install requirements via uv
RUN mkdir -p /conf
COPY requirements.in /conf/
RUN uv pip compile /conf/requirements.in -o /conf/requirements.txt
RUN uv pip install -r /conf/requirements.txt --system \
    && uv pip install --no-cache-dir awscli==1.33.37 --system

# Copy source code and install it
RUN mkdir -p /code
WORKDIR /code
ADD . /code
RUN echo "Installing dea-intertidal"
RUN uv pip install . --system

# Verify all is as expected
RUN uv pip list && uv pip check

# Run test of CLI
RUN dea-intertidal --help
