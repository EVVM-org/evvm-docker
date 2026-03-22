# Quick Start with Docker

If you prefer not to install Foundry and Bun locally, you can use Docker:

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

### Option 1: Clone this repository

```bash
git clone https://github.com/EVVM-org/evvm-docker.git
cd evvm-docker
```

### Option 2: Download files manually

Download all files from this repository and place them in a folder.

## Quick Usage

### 1. Configure your environment

```bash
# Create .env file from example
cp .env.example .env

# Edit with your RPCs and API keys
nano .env  # or use your preferred editor
```

### 2. Get the Docker image

```bash
# Option A: Pull the pre-built image (recommended, no build time)
docker pull ghcr.io/evvm-org/evvm-docker:latest

# Option B: Build locally from source
docker compose build
```

If you pulled the pre-built image, update `docker-compose.yml` to reference it instead of building:

```yaml
services:
  evvm-cli:
    # build:
    #   context: .
    #   dockerfile: Dockerfile
    image: ghcr.io/evvm-org/evvm-docker:latest
```

### 3. Import your wallet

```bash
# Open interactive shell
docker compose run --rm --entrypoint /bin/bash evvm-cli

# Inside the container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted

# Exit the container
exit
```

**Note:** Your wallet is automatically saved in a Docker volume and will persist across all future runs.

### 4. Deploy EVVM

```bash
# Using Docker Compose
docker compose run --rm evvm-cli deploy

# Or using Make
make deploy
```

## Available Commands

### Using Docker Compose (Recommended)

```bash
docker compose run --rm evvm-cli help                       # Show help
docker compose run --rm evvm-cli deploy                     # Deploy EVVM
docker compose run --rm evvm-cli register                   # Register EVVM
docker compose run --rm evvm-cli setUpCrossChainTreasuries  # Setup cross-chain
docker compose run --rm --entrypoint /bin/bash evvm-cli     # Interactive shell
docker compose run --rm evvm-cli version                    # CLI version
docker compose down --rmi all --volumes                     # Clean up Docker resources
```

### Using Make (Optional)

```bash
make help          # Show available commands
make build         # Build image
make deploy        # Deploy EVVM
make register      # Register EVVM
make shell         # Interactive shell
make version       # CLI version
make stop          # Stop containers (keep data)
make clean-image   # Remove image only (keep data)
make clean         # Remove everything
make clean-wallets # Remove only saved wallets
```

## File Structure

```
evvm-docker/
├── Dockerfile              # Docker image definition
├── compose.yml             # Service configuration
├── .dockerignore          # Files excluded from image
├── .gitignore             # Git ignored files
├── .env.example           # Configuration template
├── Makefile               # Make commands (optional)
├── QUICKSTART.md          # This guide
├── README.md              # Full documentation
└── output/                # Deployment results
```

## Environment Variables

The `.env` file should be in the same directory as `compose.yml`. Important variables:

```bash
# For single-chain deployment
RPC_URL="https://your-rpc-url"

# For cross-chain deployment
EXTERNAL_RPC_URL="https://external-chain-rpc"
HOST_RPC_URL="https://host-chain-rpc"

# For registration
EVVM_REGISTRATION_RPC_URL="https://sepolia-rpc"

# For contract verification
ETHERSCAN_API="your_api_key"
```

See [.env.example](.env.example) for all available options.

## Data Persistence

### Deployment outputs

Results are saved to `output/` which is mounted as a volume:

```bash
ls output/evvmDeployment.json
```

### Wallets

Wallets are **automatically persisted** in a Docker volume named `foundry-keystores`. You only need to import your wallet once.

To share wallets with your host machine, you can:

1. Use the default Docker volume (already configured)
2. Mount your local keystore (edit `compose.yml`):

```yaml
volumes:
  - ~/.foundry/keystores:/root/.foundry/keystores:ro
```

## Usage Examples

### Single-chain deploy on Arbitrum Sepolia

```bash
# 1. Configure .env
echo 'RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"' > .env

# 2. Build and deploy
docker compose build
docker compose run --rm evvm-cli deploy
```

### Cross-chain deploy (Sepolia + Arbitrum Sepolia)

```bash
# 1. Configure .env
cat > .env << EOF
EXTERNAL_RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
HOST_RPC_URL="https://0xrpc.io/sep"
EOF

# 2. Deploy
docker compose run --rm evvm-cli deploy
```

### Register EVVM in the registry

```bash
# 1. Make sure you deployed first
# 2. Configure Sepolia RPC
echo 'EVVM_REGISTRATION_RPC_URL="https://gateway.tenderly.co/public/sepolia"' >> .env

# 3. Register
docker compose run --rm evvm-cli register
```

### Run Foundry commands

```bash
# Compile contracts
docker compose run --rm evvm-cli forge build

# Run tests
docker compose run --rm evvm-cli forge test

# Check forge version
docker compose run --rm evvm-cli forge --version

# Start local Anvil node
docker compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0
```

## Troubleshooting

### Stop and clean up everything

To completely remove the Docker image and all data:

```bash
# Stop all running containers
docker compose down

# Remove everything: containers, images, volumes, and networks
docker compose down --rmi all --volumes --remove-orphans

# Or using Make
make clean
```

**Cleanup options:**

| Command | Removes | Keeps |
|---------|---------|-------|
| `make stop` | Nothing (just stops) | Everything |
| `make clean-wallets` | Wallets only | Image, containers, outputs |
| `make clean-image` | Docker image | Wallets, outputs |
| `make clean` | Everything | Nothing |

To rebuild from scratch after cleanup:

```bash
docker compose build
```

### Remove wallet and start fresh

If you need to delete imported wallets and start over:

```bash
# Stop and remove all containers and volumes (including wallets)
docker compose down --volumes

# Or just remove the wallet volume specifically
docker volume rm evvm-docker_foundry-keystores

# Then reimport your wallet
docker compose run --rm --entrypoint /bin/bash evvm-cli
cast wallet import defaultKey --interactive
```

### Permission errors

```bash
chmod 644 .env
chmod -R 755 output/
```

### Update repository

```bash
# Rebuild image without cache
docker compose down --rmi all --volumes
docker compose build --no-cache

# Or manually in the container
docker compose run --rm --entrypoint /bin/bash evvm-cli
git pull origin main
bun install
forge install
```

### RPC not accessible

Verify connectivity from host:

```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  https://your-rpc-url
```

## Security

⚠️ **Important:**

1. Never commit `.env` files
2. Don't store private keys in `.env`
3. Use Foundry's encrypted keystore
4. Review the Dockerfile before building
5. Use read-only mounts (`:ro`) when possible

## More Information

For complete documentation, see:
- [README.md](README.md) - Detailed Docker documentation
- https://www.evvm.info/ - Official EVVM documentation
- https://github.com/EVVM-org/Testnet-Contracts - Main EVVM repository
