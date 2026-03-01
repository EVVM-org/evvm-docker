# EVVM Docker Makefile
# Convenience commands for building and running EVVM CLI in Docker

.PHONY: help build run deploy register shell clean version stop clean-wallets clean-image rebuild logs

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
	@echo ""
	@echo "Cleanup commands:"
	@echo "  make stop     - Stop running containers (keeps data)"
	@echo "  make clean-image - Remove image only (keeps wallets/data)"
	@echo "  make clean    - Remove everything (images, containers, volumes)"
	@echo "  make clean-wallets - Remove only saved wallets"
	@echo ""
	@echo "Ensure you have created .env from .env.example before deploying"

# Build the Docker image
build:
	@echo "Building EVVM CLI Docker image..."
	docker compose build

# Run the CLI (shows help by default)
run:
	docker compose run --rm evvm-cli help

# Deploy EVVM (interactive)
deploy:
	@echo "Starting EVVM deployment..."
	docker compose run --rm evvm-cli deploy

# Register EVVM
register:
	@echo "Starting EVVM registration..."
	docker compose run --rm evvm-cli register

# Setup cross-chain treasuries
setup-cross-chain:
	@echo "Setting up cross-chain treasuries..."
	docker compose run --rm evvm-cli setUpCrossChainTreasuries

# Open interactive bash shell
shell:
	@echo "Opening interactive shell..."
	docker compose run --rm --entrypoint /bin/bash evvm-cli

# Show version
version:
	docker compose run --rm evvm-cli version

# Install dependencies (inside container)
install:
	docker compose run --rm evvm-cli install

# Run developer commands
dev:
	docker compose run --rm evvm-cli dev

# Clean up Docker resources
clean:
	@echo "Removing Docker image and containers..."
	docker compose down --rmi all --volumes --remove-orphans
	@echo "Cleanup complete (wallets and deployment data removed)"

# Remove only saved wallets
clean-wallets:
	@echo "Removing saved wallets..."
	docker volume rm evvm-docker_foundry-keystores 2>/dev/null || true
	@echo "Wallets removed. Reimport with: make shell"

# Stop running containers
stop:
	@echo "Stopping containers..."
	docker compose down
	@echo "Containers stopped (data preserved)"

# Remove only images (keep wallets and data)
clean-image:
	@echo "Removing Docker image only..."
	docker compose down --rmi all
	@echo "Image removed. Run 'make build' to rebuild"

# Rebuild without cache
rebuild:
	@echo "Rebuilding Docker image without cache..."
	docker compose build --no-cache

# Show container logs
logs:
	docker compose logs -f

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
