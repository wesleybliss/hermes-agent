FROM nousresearch/hermes-agent:latest

# Switch to root to install system dependencies and python libs
USER root

# Install libolm (required for Matrix E2EE), supervisord, and the matrix-nio package
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
        supervisor \
        python3-dev --no-install-recommends \
        procps \
        procs && \
    pip install --no-cache-dir "matrix-nio[e2e]" --break-system-packages && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/supervisor /var/run

# Copy supervisord config from your git-tracked file
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Ensure the config directory exists and has the right ownership
RUN mkdir -p /root/.hermes && chown -R 1000:1000 /root/.hermes

# Switch back to your user ID to keep permissions clean
USER 1000

# Use supervisord to run both gateway and matrix
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
