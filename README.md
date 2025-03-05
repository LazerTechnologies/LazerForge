![LazerForge Logo](.github/lazerforge_logo_pink.png)

# LazerForge

LazerForge is a Foundry template for smart contract development. For more information on Foundry check out the [foundry book](https://book.getfoundry.sh/) or jump down to [the usage section](#usage) below if you're ready to get started.

## Overview

LazerForge is a batteries included template with the following configurations:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts), [Solady](https://github.com/Vectorized/solady), and the full Uniswap suite ([v2](https://github.com/uniswap/v2-core), [v3-core](https://github.com/uniswap/v3-core) & [v3-periphery](https://github.com/uniswap/v3-periphery), [v4-core](https://github.com/uniswap/v4-core) & [v4-periphery](https://github.com/uniswap/v4-periphery)) smart contracts are included as dependencies along with [`solc` remappings](https://docs.soliditylang.org/en/latest/path-resolution.html#import-remapping) so you can work with a wide range of deployed contracts out of the box!
- `forge fmt` configured as the default formatter for VSCode projects
- Github Actions workflows that run `forge fmt --check` and `forge test` on every push and PR
  - A separate action to automatically fix formatting issues on PRs by commenting `!fix` on the PR
- A pre-configured, but still minimal `foundry.toml`
  - multiple profiles for various development and testing scenarios (see [LazerForge Profiles](exampleTutorial/profiles.md))
  - high optimizer settings by default for gas-efficient smart contracts
  - an explicit `solc` compiler version for reproducible builds
  - no extra injected `solc` metadata for simpler Etherscan verification and [deterministic cross-chain deploys via CREATE2](https://0xfoobar.substack.com/p/vanity-addresses).
  - block height and timestamp variables for [deterministic testing](#deterministic-testing)
  - mapped [network identifiers](#network-identifiers) to RPC URLs and Etherscan API keys using environment variables

## Deterministic Testing

LazerForge is configured to set fixed values for block height and timestamp which ensures that tests run against a predictable blockchain state. This makes debugging easier and guarantees that time or block-dependent logic behaves reliably.

- These values are called by Anvil and when running `forge test` so make sure to update the `block_number` and `block_timestamp` values in `foundry.toml`
- Make sure the values are set for the appropriate network you're testing against!

## Network Identifiers

When running commands like `forge verify-contract` (or using the `--verify` flag while [deploying](#deploy)), you can specify a network via CLI flags (e.g., `--chain goerli` or `--fork-url <url>`) and Forge will use the corresponding endpoint from the `foundry.toml` configuration.

- **RPC Endpoints:** The `rpc_endpoints` block links network names (`goerli`, `mainnet`, etc.) to their RPC URLs via environment variables.
- **Etherscan Configuration:** The `etherscan` block maps networks to their API keys so that when you run commands that need a block explorer—generally contract verification—Forge will use the appropriate endpoint for that network.

**Example:**

```bash
forge verify-contract --chain ethereum <contract_address> <contract_path>
```

## Usage

LazerForge can be used as a starting point or a toolkit in a wide variety of circumstances. Between OpenZeppelin, Solady, and the complete Uniswap library, you're likely to find something useful here. Here's a quick guite on how to deploy a contract.

### Quick Deploy Guide

To deploy a contract to the Goerli testnet, fund an address with 0.1 Goerli ETH, open a terminal window, and run the following commands:

Create a directory and `cd` into it:

```bash
mkdir my-lazerforge-based-project &&
cd my-lazerforge-based-project
```

Install the `foundryup` up command and run it, which in turn installs forge, cast, anvil, and chisel:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Follow the onscreen instructions output by the previous command to make Foundryup available in your CLI (or else restart your CLI).

Install forge, cast, anvil, and chisel by running:

```bash
foundryup
```

Create a new Foundry project based on LazerForge, which also initializes a new git repository, in the working directory.

```bash
forge init --template lazertechnologies/lazerforge
```

Install dependencies and compile the contracts:

```bash
forge build
```

Set up your environment variables (make sure to swap in the appropriate value for `<your_pk>`):

```bash
export GOERLI_RPC_URL='https://eth-goerli.g.alchemy.com/v2/demo' &&
export DEPLOYER_PRIVATE_KEY='<your_pk>'
```

⚠️ **Follow proper `.env` and `.gitignore` practices to prevent leaked keys.**

### Test

Tests are handled through test files, written in Solidity and using the naming convention `Contract.t.sol`

```shell
forge test
```

### Deploy

Deployments are handled through script files, written in Solidity and using the naming convention `Contract.s.sol`. You can run a script directly from your CLI

```bash
forge script script/MyContract.s.sol:MyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key> --chain-id <chain_id> -vv
```

> 💡 If a deployment script contains multiple functions, you can run a single function by appending the file name in the previous script like this `forge script script/MyScript.s.sol:MyFunction`.

Unless you include the `--broadcast` argument, the script will be run in a simulated environment. If you need to run the script live, use the `--broadcast` arg

⚠️ **Using `--broadcast` will initiate an onchain transaction, only use after thoroughly testing**

```bash
forge script script/MyContract.s.sol:MyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key> --chain-id 1 -vv --broadcast
```

Additional arguments can specity the chain and verbosity of the script

```bash
forge script script/MyContract.s.sol:MyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key> --chain-id 1 -vv
```

Additionally, you can pass a private key directly into script functions to prevent exposing it in the command line (recommended).

⚠️ **NEVER place your private key inside of a script, always use secure environment variables!**

```js
function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    // rest of your code...
}
```

Then run the `forge script` command without the private key arg.

💡 **When deploying a new contract, you can use the `--verify` arg to verify the contract on deployment.**

### More Details

See [the tutorial](exampleTutorial) for more detail on modifying the example contract, writing tests, deploying, and more.

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
