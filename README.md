![LazerForge Logo](.github/lazerforge_logo_pink.png)

# LazerForge

LazerForge is a Foundry template for smart contract development. For more information on Foundry check out the [foundry book](https://book.getfoundry.sh/).

## Overview

LazerForge is a batteries included template with the following configurations:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts), [Solady](https://github.com/Vectorized/solady), and the full Uniswap suite ([v2](https://github.com/uniswap/v2-core), [v3-core](https://github.com/uniswap/v3-core) & [v3-periphery](https://github.com/uniswap/v3-periphery), [v4-core](https://github.com/uniswap/v4-core) & [v4-periphery](https://github.com/uniswap/v4-periphery)) smart contracts are included as dependencies along with [`solc` remappings](https://docs.soliditylang.org/en/latest/path-resolution.html#import-remapping) so you can work with a wide range of deployed contracts out of the box!
- `forge fmt` configured as the default formatter for VSCode projects
- Github Actions workflows that run `forge fmt --check` and `forge test` on every push and PR
  - A separate action to automatically fix formatting issues on PRs by commenting `!fix` on the PR
- A pre-configured, but still minimal `foundry.toml`
  - multiple profiles for various development and testing scenarios (see [LazerForge Profiles](lazerTutorial/profiles.md))
  - high optimizer settings by default for gas-efficient smart contracts
  - an explicit `solc` compiler version for reproducible builds
  - no extra injected `solc` metadata for simpler Etherscan verification and [deterministic cross-chain deploys via CREATE2](https://0xfoobar.substack.com/p/vanity-addresses).
  - block height and timestamp variables for [deterministic testing](lazerTutorial/testing.md)
  - mapped [network identifiers](lazerTutorial/networks.md) to RPC URLs and Etherscan API keys using environment variables

## Quick Start

1. Install Foundry:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. Create a new project using one of the templates:

Full repo with example contracts, Uniswap dependencies, and docs:

```bash
forge init --template lazertechnologies/lazerforge <project_name>
```

[Minimal repo](#branch-structure) with just optimized config:

```bash
forge init --template lazertechnologies/lazerforge --branch minimal <project_name>
```

- DeFi Starter: 🚧 coming soon
- NFT Starter: 🚧 coming soon
- Stablecoin Starter: 🚧 coming soon
- Cross-Chain starter: 🚧 coming soon

1. Build the project:

```bash
forge build
```

## Branch Structure

LazerForge maintains two primary branches to cater to different needs:

- **`main` Branch**: Contains tutorials, additional example contracts, and comprehensive dependencies.
- **`minimal` Branch**: Provides a lightweight template without extra tutorials and dependencies.

For detailed info on branches and contribution, check out the [Contributing Guide](CONTRIBUTING.md).

> See [sync script usage](CONTRIBUTING.md#syncing-changes-between-branches) for automating branch sync.

## Reinitialize Submodules

When working across branches with different dependencies, submodules may need to be reinitialized. Run

```bash
./reinit-submodules
```

## Gas Snapshots

Forge can generate gas snapshots for all test functions to see how much gas contracts will consume, or to compare gas usage before and after optimizations.

```shell
forge snapshot
```

## Coverage Reports

If you plan on generating coverage reports, you'll need to install [`lcov`](https://github.com/linux-test-project/lcov) as well.

On macOS, you can do this with the following command:

```bash
brew install lcov
```

To generate reports, run

```bash
./coverage-report
```

## Documentation

For detailed guides on various aspects of LazerForge, check out:

- [Setup Guide](lazerTutorial/setup.md) - Initial setup and configuration
- [Testing Guide](lazerTutorial/testing.md) - Writing and running tests
- [Deployment Guide](lazerTutorial/deployment.md) - Deploying contracts
- [Network Configuration](lazerTutorial/networks.md) - Setting up networks and RPC endpoints
- [Profiles](lazerTutorial/profiles.md) - Using different Foundry profiles
