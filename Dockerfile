FROM nousresearch/hermes-agent:latest

# Switch to root to install system dependencies and python libs
USER root

# Install libolm (required for Matrix E2EE), and the matrix-nio package
# The image is Debian-based, so we use apt
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        ripgrep \
        ffmpeg \
        libolm-dev \
        gcc \
        pkg-config \
        libffi-dev \
        libssl-dev \
        python3-dev --no-install-recommends \
        procps \
        procs \
        cron \
        htop \
        nano \
        jq && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir 'hermes-agent[matrix]' --break-system-packages

# Ensure the config directory exists and has the right ownership
RUN mkdir -p /root/.hermes && chown -R 1000:1000 /root/.hermes

# Switch back to root to keep permissions clean
USER 1000
