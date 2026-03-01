# Quick Start with Docker

If you prefer not to install Foundry and Bun locally, you can use Docker:

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Installation

### Option 1: Clone this repository

```bash
git clone https://github.com/YOUR-USERNAME/evvm-docker.git
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

### 2. Build the Docker image

```bash
# Using docker-compose (recommended)
docker-compose build

# Or using Make
make build
```

### 3. Import your wallet

```bash
# Open interactive shell
docker-compose run --rm evvm-cli /bin/bash

# Inside the container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted

# Exit the container
exit
```

### 4. Deploy EVVM

```bash
# Using docker-compose
docker-compose run --rm evvm-cli deploy

# Or using Make
make deploy
```

## Available Commands

### Using docker-compose (Recommended)

```bash
docker-compose run --rm evvm-cli help                       # Show help
docker-compose run --rm evvm-cli deploy                     # Deploy EVVM
docker-compose run --rm evvm-cli register                   # Register EVVM
docker-compose run --rm evvm-cli setUpCrossChainTreasuries  # Setup cross-chain
docker-compose run --rm evvm-cli /bin/bash                  # Interactive shell
docker-compose run --rm evvm-cli version                    # CLI version
docker-compose down --rmi all --volumes                     # Clean up Docker resources
```

### Using Make (Optional)

```bash
make help       # Show available commands
make build      # Build image
make deploy     # Deploy EVVM
make register   # Register EVVM
make shell      # Interactive shell
make version    # CLI version
make clean      # Clean up resources
```

## File Structure

```
evvm-docker/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Service configuration
├── .dockerignore          # Files excluded from image
├── .gitignore             # Git ignored files
├── .env.example           # Configuration template
├── Makefile               # Make commands (optional)
├── QUICKSTART.md          # This guide
├── README.md              # Full documentation
└── output/                # Deployment results
```

## Environment Variables

The `.env` file should be in the same directory as `docker-compose.yml`. Important variables:

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

To persist wallets between runs, you can:

1. Importar dentro del contenedor cada vez
2. Montar tu keystore local (edita `docker-compose.yml`):

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
docker-compose build
docker-compose run --rm evvm-cli deploy
```

### Cross-chain deploy (Sepolia + Arbitrum Sepolia)

```bash
# 1. Configure .env
cat > .env << EOF
EXTERNAL_RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
HOST_RPC_URL="https://0xrpc.io/sep"
EOF

# 2. Deploy
docker-compose run --rm evvm-cli deploy
```

### Register EVVM in the registry

```bash
# 1. Make sure you deployed first
# 2. Configure Sepolia RPC
echo 'EVVM_REGISTRATION_RPC_URL="https://gateway.tenderly.co/public/sepolia"' >> .env

# 3. Register
docker-compose run --rm evvm-cli register
```

### Run Foundry commands

```bash
# Compile contracts
docker-compose run --rm evvm-cli forge build

# Run tests
docker-compose run --rm evvm-cli forge test

# Check forge version
docker-compose run --rm evvm-cli forge --version

# Start local Anvil node
docker-compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0
```

## Troubleshooting

### Permission errors

```bash
chmod 644 .env
chmod -R 755 output/
```

### Update repository

```bash
# Rebuild image without cache
docker-compose down --rmi all --volumes
docker-compose build --no-cache

# Or manually in the container
docker-compose run --rm evvm-cli /bin/bash
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
