# EVVM Docker

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
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

```bash
docker-compose build
```

Or using Make:

```bash
make build
```

### 4. Import Your Wallet

```bash
# Start interactive session
docker-compose run --rm evvm-cli /bin/bash

# Inside container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted
exit
```

### 5. Deploy EVVM

```bash
# Using docker-compose
docker-compose run --rm evvm-cli deploy

# Or using Make
make deploy
```

## File Structure

```
evvm-docker/
├── 📄 README.md              # This file
├── 📄 QUICKSTART.md          # Quick start guide
├── 🐳 Dockerfile             # Docker image definition
├── 🐳 docker-compose.yml     # Docker Compose configuration
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

### Option 1: Import wallet inside container

```bash
# Start interactive session
docker-compose run --rm evvm-cli /bin/bash

# Inside container, import your wallet
cast wallet import defaultKey --interactive
# Enter your private key when prompted

# Then run CLI commands
bun run cli/index.ts deploy
exit
```

**Note:** Wallet will be lost when container is removed unless you mount the keystore directory.

### Option 2: Share Foundry keystore from host (Recommended for persistence)

Uncomment the volume in `docker-compose.yml`:

```yaml
volumes:
  - ~/.foundry/keystores:/root/.foundry/keystores:ro
```

Then import wallet on your host machine:

```bash
cast wallet import defaultKey --interactive
```

Your wallet will now be available in all container runs.

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

### Using docker-compose (Recommended)

```bash
docker-compose run --rm evvm-cli help                       # Show CLI help
docker-compose run --rm evvm-cli version                    # Display version
docker-compose run --rm evvm-cli deploy                     # Deploy EVVM
docker-compose run --rm evvm-cli register                   # Register EVVM
docker-compose run --rm evvm-cli setUpCrossChainTreasuries  # Setup cross-chain
docker-compose run --rm evvm-cli dev                        # Developer utilities
docker-compose run --rm evvm-cli install                    # Install dependencies
docker-compose run --rm evvm-cli /bin/bash                  # Interactive shell
```

### Using Make (Optional)

```bash
make help       # Show all available commands
make build      # Build Docker image
make deploy     # Deploy EVVM
make register   # Register EVVM
make shell      # Interactive shell
make version    # Show version
make clean      # Remove containers and images
```

## Examples

### Deploy EVVM on a single chain

```bash
# 1. Configure .env
echo 'RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"' > .env

# 2. Run deployment
docker-compose run --rm evvm-cli deploy
```

### Deploy cross-chain EVVM

```bash
# 1. Configure .env
cat > .env << EOF
EXTERNAL_RPC_URL="https://sepolia-rollup.arbitrum.io/rpc"
HOST_RPC_URL="https://0xrpc.io/sep"
EOF

# 2. Run deployment
docker-compose run --rm evvm-cli deploy
```

### Register EVVM in the registry

```bash
# 1. Ensure you have deployed first
# 2. Configure registration RPC
echo 'EVVM_REGISTRATION_RPC_URL="https://gateway.tenderly.co/public/sepolia"' >> .env

# 3. Run registration
docker-compose run --rm evvm-cli register
```

### Run Foundry commands

```bash
# Compile contracts
docker-compose run --rm evvm-cli forge build

# Run tests
docker-compose run --rm evvm-cli forge test

# Start local testnet (Anvil)
docker-compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0

# Use cast to check block number
docker-compose run --rm evvm-cli cast block-number --rpc-url https://eth.llamarpc.com
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
docker-compose run --rm evvm-cli forge test

# Run anvil (local testnet)
docker-compose run --rm -p 8545:8545 evvm-cli anvil --host 0.0.0.0

# Use cast
docker-compose run --rm evvm-cli cast block-number --rpc-url https://eth.llamarpc.com
```

### Development mode

For development with live code changes, mount the source directory:

Edit `docker-compose.yml`:

```yaml
volumes:
  - ../:/workspace
```

Then rebuild inside container:

```bash
docker-compose run --rm evvm-cli /bin/bash
bun install
forge build
```

## Troubleshooting

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

- Use `network_mode: host` in docker-compose.yml if accessing local nodes

### Update repository

The repository is cloned during build. To update:

```bash
# Rebuild the image without cache
docker-compose down --rmi all --volumes
docker-compose build --no-cache
```

Or manually inside container:

```bash
docker-compose run --rm evvm-cli /bin/bash
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



