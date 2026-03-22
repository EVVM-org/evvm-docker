# EVVM Docker

[![Docker Image](https://ghcr-badge.egpl.dev/evvm-org/evvm-docker/latest_tag?trim=major&label=ghcr.io&color=2496ED)](https://github.com/EVVM-org/evvm-docker/pkgs/container/evvm-docker)
[![Foundry](https://img.shields.io/badge/Foundry-Included-FFDB1C?logo=foundry)](https://getfoundry.sh/)
[![Bun](https://img.shields.io/badge/Bun-Included-000000?logo=bun)](https://bun.sh/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Containerized environment for deploying and managing [EVVM Testnet Contracts](https://github.com/EVVM-org/Testnet-Contracts) without installing dependencies locally.

Deploy virtual EVM chains on testnets using Docker - no need to install Foundry, Bun, or manage dependencies manually. This repository provides a complete Docker environment with all tools pre-configured and ready to use.

## What's Included

- **Docker Image** with Foundry (forge, cast, anvil, chisel) and Bun pre-installed
- **Auto-cloning** of the [EVVM Testnet Contracts](https://github.com/EVVM-org/Testnet-Contracts) repository
- **EVVM CLI** pre-configured and ready to use
- **Complete documentation** with examples and guides
- **Make targets** for common operations (optional)
- **Secure wallet management** using Foundry's encrypted keystores
- All project dependencies pre-installed

## Quick Start

### 1. Clone or Download

```bash
git clone https://github.com/EVVM-org/evvm-docker
cd evvm-docker
```

Or download and extract the files manually.

### 2. Configure Environment

Create your `.env` file from the example:

```bash
cp .env.example .env
# Edit .env with your RPC URLs and API keys
nano .env
```

### 3. Build Docker Image

You can either pull the pre-built image from GHCR or build it locally:

```bash
# Option A: Pull pre-built image (faster)
docker pull ghcr.io/evvm-org/evvm-docker:latest

# Option B: Build locally
docker compose build
```

Or using Make (builds locally):

```bash
make build
```

### 4. Import Your Wallet

```bash
# Start interactive session
docker compose run --rm --entrypoint /bin/bash evvm-cli

# Inside container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted
exit
```

### 5. Deploy EVVM

```bash
# Using docker compose
docker compose run --rm evvm-cli deploy

# Or using Make
make deploy
```

## File Structure

```
evvm-docker/
├── 📄 README.md              # This file
├── 📄 QUICKSTART.md          # Quick start guide
├── 🐳 Dockerfile             # Docker image definition
├── 🐳 compose.yml            # Docker Compose configuration
├── 📝 .env.example           # Environment variables template
├── 🔧 Makefile               # Make commands (optional)
├── 📄 LICENSE                # MIT License
├── 🙈 .dockerignore          # Docker build exclusions
└── 🙈 .gitignore             # Git exclusions
```

## Use Cases

Perfect for:

- **Testing EVVM** without installing Foundry/Bun locally
- **CI/CD pipelines** requiring consistent environments
- **Team development** with standardized tooling
- **Windows users** wanting easy access to Foundry tools
- **Quick deployments** on any platform with Docker

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (2.0+)
- At least 4GB of free disk space

## Working with Wallets

### Option 1: Import wallet inside container (Persistent)

Wallets are automatically persisted in a Docker volume, so you only need to import once:

```bash
# Start interactive session (only needed once for import)
docker compose run --rm --entrypoint /bin/bash evvm-cli

# Inside container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted

# Then run CLI commands
bun run cli/index.ts deploy
exit
```

**Note:** Your wallet will persist across container runs thanks to the `foundry-keystores` volume.

### Option 2: Share Foundry keystore from host (Recommended for persistence)

**Note:** By default, wallets are now persisted in a Docker volume named `foundry-keystores`. They will be available across all container runs.

If you want to share wallets with your host machine instead, uncomment the alternative volume mount in `compose.yml`:

```yaml
volumes:
  # Comment out the volume mount
  # - foundry-keystores:/root/.foundry/keystores
  
  # Uncomment the host mount
  - ~/.foundry/keystores:/root/.foundry/keystores:ro
```

Then import wallet on your host machine:

```bash
cast wallet import defaultKey --interactive
```

Your wallet will now be available in all container runs from both host and containers.

## Environment Variables

Required variables in `.env`:

```bash
# For single-chain deployment
RPC_URL="https://your-rpc-url"

# For cross-chain deployment
EXTERNAL_RPC_URL="https://external-chain-rpc"
HOST_RPC_URL="https://host-chain-rpc"

# For registration
EVVM_REGISTRATION_RPC_URL="https://sepolia-rpc-url"

# For contract verification
ETHERSCAN_API="your_api_key"
```

See `.env.example` for all available options.

## Available Commands

### Using Docker Compose (Recommended)

```bash
docker compose run --rm evvm-cli help                       # Show CLI help
docker compose run --rm evvm-cli version                    # Display version
docker compose run --rm evvm-cli deploy                     # Deploy EVVM
docker compose run --rm evvm-cli register                   # Register EVVM
docker compose run --rm evvm-cli setUpCrossChainTreasuries  # Setup cross-chain
docker compose run --rm evvm-cli dev                        # Developer utilities
docker compose run --rm evvm-cli install                    # Install dependencies
docker compose run --rm --entrypoint /bin/bash evvm-cli     # Interactive shell
```

### Using Make (Optional)

```bash
make help          # Show all available commands
make build         # Build Docker image
make deploy        # Deploy EVVM
make register      # Register EVVM
make shell         # Interactive shell
make version       # Show version
make stop          # Stop containers (keep data)
make clean-image   # Remove image only (keep wallets/data)
make clean         # Remove everything (images + wallets + data)
make clean-wallets # Remove only saved wallets
```

## Examples

### Deploy EVVM on a single chain

```bash
# 1. Configure .env
echo 'RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"' > .env

# 2. Run deployment
docker compose run --rm evvm-cli deploy
```

### Deploy cross-chain EVVM

```bash
# 1. Configure .env
cat > .env << EOF
EXTERNAL_RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
HOST_RPC_URL="https://0xrpc.io/sep"
EOF

# 2. Run deployment
docker compose run --rm evvm-cli deploy
```

### Register EVVM in the registry

```bash
# 1. Ensure you have deployed first
# 2. Configure registration RPC
echo 'EVVM_REGISTRATION_RPC_URL="https://gateway.tenderly.co/public/sepolia"' >> .env

# 3. Run registration
docker compose run --rm evvm-cli register
```

### Run Foundry commands

```bash
# Compile contracts
docker compose run --rm evvm-cli forge build

# Run tests
docker compose run --rm evvm-cli forge test

# Start local testnet (Anvil)
docker compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0

# Use cast to check block number
docker compose run --rm evvm-cli cast block-number --rpc-url https://eth.llamarpc.com
```

## Persisting Data

### Deployment outputs

Deployment results are saved to `output/` directory which is mounted as a volume. This ensures your deployment data persists across container runs.

```bash
# View deployment results
ls output/evvmDeployment.json
```

### Wallet keystores

If you import a wallet inside the container without mounting the keystore directory, it will be lost when the container is removed. Use **Option 2** in the [Working with Wallets](#-working-with-wallets) section to persist wallets.

## Advanced Usage

### Run specific Foundry commands

```bash
# Run forge tests
docker compose run --rm evvm-cli forge test

# Run anvil (local testnet)
docker compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0

# Use cast
docker compose run --rm evvm-cli cast block-number --rpc-url https://eth.llamarpc.com
```

### Development mode

For development with live code changes, mount the source directory:

Edit `compose.yml`:

```yaml
volumes:
  - ../:/workspace
```

Then rebuild inside container:

```bash
docker compose run --rm --entrypoint /bin/bash evvm-cli
bun install
forge build
```

## Troubleshooting

### Stop containers and remove everything

To pause or completely remove the Docker setup:

```bash
# Just stop running containers (data persists)
docker compose stop
# Or
make stop

# Stop and remove containers (volumes/data persist)
docker compose down

# Remove image but keep wallets and data
docker compose down --rmi all
# Or
make clean-image

# Complete cleanup: remove containers, images, volumes, and all data
docker compose down --rmi all --volumes --remove-orphans
# Or
make clean
```

**Cleanup comparison:**

| Action | Command | Image | Wallets | Outputs | Containers |
|--------|---------|-------|---------|---------|------------|
| **Stop** | `make stop` | ✅ Keep | ✅ Keep | ✅ Keep | ⏸️ Stop |
| **Clean wallets** | `make clean-wallets` | ✅ Keep | ❌ Remove | ✅ Keep | 🗑️ Remove |
| **Clean image** | `make clean-image` | ❌ Remove | ✅ Keep | ✅ Keep | 🗑️ Remove |
| **Clean all** | `make clean` | ❌ Remove | ❌ Remove | ❌ Remove | 🗑️ Remove |

To verify everything is removed:

```bash
# Check images
docker images | grep evvm

# Check volumes  
docker volume ls | grep evvm-docker

# Check containers
docker ps -a | grep evvm
```

### Remove wallets and start fresh

If you need to delete imported wallets:

```bash
# Remove the wallet volume
docker volume rm evvm-docker_foundry-keystores

# Or remove all data (wallets + outputs)
docker compose down --volumes
```

Then reimport your wallet as described in [Working with Wallets](#-working-with-wallets).

### Docker not running

```bash
# Linux
sudo systemctl start docker

# macOS
open -a Docker

# Windows
# Start Docker Desktop from Start menu
```

### Permission issues

If you encounter permission errors with mounted volumes:

```bash
# On Linux, ensure proper permissions
chmod 644 .env
chmod -R 755 output/

# Linux - add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Network connectivity

If RPC URLs are not accessible:

```bash
# Test from host
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  YOUR_RPC_URL
```

- Use `network_mode: host` in compose.yml if accessing local nodes

### Update repository

The repository is cloned during build. To update:

```bash
# Rebuild the image without cache
docker compose down --rmi all --volumes
docker compose build --no-cache
```

Or manually inside container:

```bash
docker compose run --rm --entrypoint /bin/bash evvm-cli
git pull origin main
git submodule update --init --recursive
bun install
forge install
```

## Security

**Important Security Practices:**

1. **Never commit `.env` files** - Keep your RPC URLs and API keys secret
2. **Never store private keys in `.env`** - Use Foundry's encrypted keystore
3. **Use read-only mounts** (`:ro`) for sensitive files when possible
4. **Be cautious with volume mounts** - Only mount necessary directories
5. **Review the Dockerfile** before building to understand what's installed
6. **Keep Docker images updated** - Rebuild periodically for security patches

## Security

**Important Security Practices:**

1. **Never commit `.env` files** - Keep your RPC URLs and API keys secret
2. **Never store private keys in `.env`** - Use Foundry's encrypted keystore
3. **Use read-only mounts** (`:ro`) for sensitive files when possible
4. **Be cautious with volume mounts** - Only mount necessary directories
5. **Review the Dockerfile** before building to understand what's installed
6. **Keep Docker images updated** - Rebuild periodically for security patches

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide
- **[README.md](README.md)** - Full documentation (this file)
- **[EVVM Docs](https://www.evvm.info/)** - Official EVVM documentation
- **[Foundry Book](https://book.getfoundry.sh/)** - Foundry documentation
- **[Bun Docs](https://bun.sh/docs)** - Bun documentation

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Links

- **EVVM Website:** https://www.evvm.info/
- **EVVM Testnet Contracts:** https://github.com/EVVM-org/Testnet-Contracts
- **Docker Hub:** (Coming soon)
- **Documentation:** https://www.evvm.info/docs/



