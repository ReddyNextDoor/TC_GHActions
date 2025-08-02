# Use Ubuntu 22.04 ARM64 for Apple Silicon
FROM ubuntu:22.04

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install basic deps + curl + .NET dependencies + git
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    tar \
    bash \
    git \
    jq \
    libicu70 \
    libssl3 \
    libkrb5-3 \
    zlib1g \
    libgcc-s1 \
    libgssapi-krb5-2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a user for running the runner (no sudo here)
RUN useradd -m runner && mkdir -p /actions-runner /runner-data && chown -R runner:runner /actions-runner /runner-data

# Create volume mount point for persistence
VOLUME ["/runner-data"]

WORKDIR /actions-runner

USER runner

# Download & verify the GitHub Actions runner tarball (ARM64)
RUN curl -o actions-runner-linux-arm64-2.327.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.327.1/actions-runner-linux-arm64-2.327.1.tar.gz && \
    tar xzf actions-runner-linux-arm64-2.327.1.tar.gz && \
    rm actions-runner-linux-arm64-2.327.1.tar.gz

# Copy entrypoint script
COPY entrypoint.sh /actions-runner/entrypoint.sh

# Make entrypoint executable
USER root
RUN chmod +x /actions-runner/entrypoint.sh
USER runner

# Entrypoint script to easily configure & run the runner as non-root
ENTRYPOINT ["/actions-runner/entrypoint.sh"]

