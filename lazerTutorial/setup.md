# Setup Guide

This guide covers the initial setup and configuration of your LazerForge project.

## Prerequisites

Before starting with LazerForge, make sure you have the following installed:

1. Git
2. Node.js (for development tools)
3. Code editor (VSCode + Solidity extension recommended)

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

1. Copy `sample.env` into a new local `.env` file in your project root:

```bash
cp sample.env .env

```

2. Add your environment variables to `.env`:

```env
SEPOLIA_RPC_URL='your-rpc-url'
ETHERSCAN_API_KEY='your-api-key'
DEPLOYER_PRIVATE_KEY='your-private-key'
```

3. Ensure `.env` is included in your `.gitignore`:

```bash
echo ".env" >> .gitignore
```

## VSCode Configuration

LazerForge comes pre-configured with VSCode settings:

- `forge fmt` is set as the default formatter for Solidity files
- Recommended extensions: [Solidity](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity)

## Project Structure

```bash
├── src/                               # example contracts
│   └── utils/                       # utility contracts
├── test/                              # test files
├── script/                           # example scripts
├── .github/                        # GitHub Actions workflows
├── lazerTutorial/               # LazerForge tutorial
└── foundry.toml                # foundry config
```

## Dependencies

LazerForge comes with some common dependencies out of the box:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Solady](https://github.com/Vectorized/solady)
- Uniswap
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

---

**Navigation:**

- [← Back to Tutorial Overview](README.md)
- [Next: Testing Guide →](testing.md)
