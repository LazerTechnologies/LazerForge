![LazerForge Logo](.github/lazerforge_logo_pink.png)

# LazerForge

LazerForge is a Foundry template for smart contract development. For more information on Foundry check out the [foundry book](https://book.getfoundry.sh/).

## Overview

LazerForge is a batteries included template with the following configurations:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts), [Solady](https://github.com/Vectorized/solady), and the full Uniswap suite ([v2](https://github.com/uniswap/v2-core), [v3-core](https://github.com/uniswap/v3-core) & [v3-periphery](https://github.com/uniswap/v3-periphery), [v4-core](https://github.com/uniswap/v4-core) & [v4-periphery](https://github.com/uniswap/v4-periphery)) smart contracts are included as dependencies along with [`solc` remappings](https://docs.soliditylang.org/en/latest/path-resolution.html#import-remapping) so you can work with a wide range of deployed contracts out of the box!
- Dependencies managed with [Soldeer](https://soldeer.xyz) — declared in `foundry.toml` and version-locked in `soldeer.lock`, so they can be added, removed, and upgraded with a single command
- `forge fmt` configured as the default formatter for VSCode projects
- Github Actions workflows that run `forge fmt --check` and `forge test` on every push and PR
  - A separate action to automatically fix formatting issues on PRs by commenting `!fix` on the PR
- A `justfile` with the common Foundry recipes (`just --list`)
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

3. Install dependencies:

```bash
forge soldeer install
```

4. Build the project:

```bash
forge build
```

## Branch Structure

- **`main` Branch**: Contains tutorials, additional example contracts, and comprehensive dependencies.
- **`minimal` Branch**: Provides a lightweight template without extra tutorials and dependencies.

`minimal` is generated from `main` — it is a build artifact, described by a manifest in [`variants/`](variants/) and rebuilt by CI on every push. Contributors only ever work on `main`.

For detailed info on branches and contribution, check out the [Contributing Guide](CONTRIBUTING.md).

## Dependencies

Dependencies are managed with [Soldeer](https://soldeer.xyz). They are declared in the `[dependencies]` section of `foundry.toml` and pinned by version and content hash in `soldeer.lock`. The `dependencies/` directory itself is generated and git-ignored, so a fresh clone needs one command before it will build:

```bash
forge soldeer install
```

Run the same command after pulling changes that touch `foundry.toml`, or after switching branches.

To add, remove, or upgrade a dependency:

```bash
forge soldeer install <name>~<version>   # add
forge soldeer uninstall <name>           # remove
forge soldeer update                     # upgrade within declared ranges
```

Remappings are maintained by hand in `foundry.toml` rather than generated, so the template can keep import aliases like `@openzeppelin/contracts/`. The paths include the version number — update the matching remapping whenever you change a dependency's version.

The Uniswap aliases resolve to the package root, matching the import paths in Uniswap's own documentation. These packages import each other by their full published path, so the alias cannot point any deeper:

```solidity
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
```

## Commands

Common tasks live in the `justfile`. [Install just](https://github.com/casey/just#installation), then run `just` (or `just --list`) to see them:

```bash
just build       # forge build
just test        # forge test
just fmt         # forge fmt
just lint        # forge lint
just snapshot    # forge snapshot
just cov         # coverage summary + HTML report
```

Recipes accept extra flags (`just test --match-test test_Deposit`). `just cov` needs [`lcov`](https://github.com/linux-test-project/lcov) (`brew install lcov` on macOS) and uses a `[profile.coverage]` with the optimizer off so instrumentation does not hit "stack too deep".

## Documentation

For detailed guides on various aspects of LazerForge, check out:

- [Setup Guide](lazerTutorial/setup.md) - Initial setup and configuration
- [Testing Guide](lazerTutorial/testing.md) - Writing and running tests
- [Deployment Guide](lazerTutorial/deployment.md) - Deploying contracts
- [Network Configuration](lazerTutorial/networks.md) - Setting up networks and RPC endpoints
- [Profiles](lazerTutorial/profiles.md) - Using different Foundry profiles
