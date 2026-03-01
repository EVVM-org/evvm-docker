# EVVM Testnet Contracts - Docker Image
# This image provides a complete environment to interact with the EVVM CLI
# including Foundry, Bun, and all necessary dependencies.

FROM debian:bookworm-slim

# Metadata
LABEL maintainer="EVVM Organization"
LABEL description="EVVM Testnet Contracts CLI - Interactive deployment and management tool"
LABEL version="3.0.2"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Foundry (forge, cast, anvil, chisel)
RUN curl -L https://foundry.paradigm.xyz | bash && \
    . ~/.bashrc && \
    foundryup

# Add Foundry to PATH
ENV PATH="/root/.foundry/bin:${PATH}"

# Install Bun (JavaScript/TypeScript runtime)
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
ENV PATH="/root/.bun/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Clone the EVVM Testnet Contracts repository
RUN git clone --recursive https://github.com/EVVM-org/Testnet-Contracts.git . && \
    git submodule update --init --recursive

# Install project dependencies
RUN bun install && \
    forge install

# Create a directory for user's .env file
RUN mkdir -p /workspace/.env.d

# Set the CLI as executable
RUN chmod +x ./evvm ./evvm.bat

# Environment variable to support .env file mounting
ENV EVVM_ENV_FILE="/workspace/.env"

# Default command: show help
ENTRYPOINT ["bun", "run", "cli/index.ts"]
CMD ["help"]

# Health check (verify Foundry and Bun are available)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD forge --version && bun --version || exit 1
