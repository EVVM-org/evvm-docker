# EVVM Docker Makefile
# Convenience commands for building and running EVVM CLI in Docker

.PHONY: help build run deploy register shell clean version stop

# Default target
help:
	@echo "EVVM Docker - Available commands:"
	@echo ""
	@echo "  make build    - Build the Docker image"
	@echo "  make run      - Run CLI with help command"
	@echo "  make deploy   - Run EVVM deployment (interactive)"
	@echo "  make register - Run EVVM registration (interactive)"
	@echo "  make shell    - Open interactive bash shell"
	@echo "  make version  - Show EVVM CLI version"
	@echo "  make clean    - Remove Docker image and containers"
	@echo "  make stop     - Stop running containers"
	@echo ""
	@echo "Ensure you have created .env from .env.example before deploying"

# Build the Docker image
build:
	@echo "Building EVVM CLI Docker image..."
	docker-compose build

# Run the CLI (shows help by default)
run:
	docker-compose run --rm evvm-cli help

# Deploy EVVM (interactive)
deploy:
	@echo "Starting EVVM deployment..."
	docker-compose run --rm evvm-cli deploy

# Register EVVM
register:
	@echo "Starting EVVM registration..."
	docker-compose run --rm evvm-cli register

# Setup cross-chain treasuries
setup-cross-chain:
	@echo "Setting up cross-chain treasuries..."
	docker-compose run --rm evvm-cli setUpCrossChainTreasuries

# Open interactive bash shell
shell:
	@echo "Opening interactive shell..."
	docker-compose run --rm evvm-cli /bin/bash

# Show version
version:
	docker-compose run --rm evvm-cli version

# Install dependencies (inside container)
install:
	docker-compose run --rm evvm-cli install

# Run developer commands
dev:
	docker-compose run --rm evvm-cli dev

# Clean up Docker resources
clean:
	@echo "Removing Docker image and containers..."
	docker-compose down --rmi all --volumes --remove-orphans
	@echo "Cleanup complete"

# Stop running containers
stop:
	docker-compose down

# Rebuild without cache
rebuild:
	@echo "Rebuilding Docker image without cache..."
	docker-compose build --no-cache

# Show container logs
logs:
	docker-compose logs -f

# Quick setup guide
setup:
	@echo "EVVM Docker Quick Setup:"
	@echo ""
	@echo "1. Create environment file:"
	@echo "   cd .. && cp .env.example .env"
	@echo ""
	@echo "2. Edit .env with your configuration:"
	@echo "   nano ../.env"
	@echo ""
	@echo "3. Build the Docker image:"
	@echo "   make build"
	@echo ""
	@echo "4. Import wallet (in interactive shell):"
	@echo "   make shell"
	@echo "   cast wallet import defaultKey --interactive"
	@echo ""
	@echo "5. Deploy EVVM:"
	@echo "   make deploy"
