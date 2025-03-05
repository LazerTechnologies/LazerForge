# Setup Guide

This guide covers the initial setup and configuration of your LazerForge project.

## Prerequisites

Before starting with LazerForge, make sure you have the following installed:

1. Git
2. Node.js (for development tools)
3. A code editor (VSCode recommended)

## Installation

1. Install Foundry using `foundryup`:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Create a new LazerForge project:

```bash
forge init --template lazertechnologies/lazerforge
```

3. Install dependencies:

```bash
forge build
```

## Environment Setup

1. Create a `.env` file in your project root:

```bash
touch .env
```

2. Add your environment variables to `.env`:

```env
GOERLI_RPC_URL='your-rpc-url'
ETHERSCAN_API_KEY='your-api-key'
DEPLOYER_PRIVATE_KEY='your-private-key'
```

3. Add `.env` to your `.gitignore`:

```bash
echo ".env" >> .gitignore
```

## VSCode Configuration

LazerForge comes pre-configured with VSCode settings:

- `forge fmt` is set as the default formatter for Solidity files
- Recommended extensions are suggested
- Editor settings are optimized for Solidity development

## Project Structure

```
├── src/                    # Source files
├── test/                   # Test files
├── script/                 # Deployment scripts
├── .github/               # GitHub Actions workflows
├── foundry.toml           # Foundry configuration
└── remappings.txt         # Solidity import remappings
```

## Dependencies

LazerForge includes several key dependencies:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Solady](https://github.com/Vectorized/solady)
- Uniswap suite:
  - [v2](https://github.com/uniswap/v2-core)
  - [v3-core](https://github.com/uniswap/v3-core)
  - [v3-periphery](https://github.com/uniswap/v3-periphery)
  - [v4-core](https://github.com/uniswap/v4-core)
  - [v4-periphery](https://github.com/uniswap/v4-periphery)

## Next Steps

After setup, you can:

1. [Write tests](testing.md)
2. [Deploy contracts](deployment.md)
3. [Configure networks](networks.md)
4. [Use different profiles](profiles.md)
