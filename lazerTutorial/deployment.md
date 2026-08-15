# Deployment Guide

This guide covers how to deploy contracts using LazerForge.

## Quick Deploy Guide

To deploy a contract to the Sepolia testnet, fund an address with 0.1 Sepolia ETH, open a terminal window, and run the following commands:

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
forge soldeer install
forge build
```

Fill in the RPC URL (and any explorer API keys) for the network you are deploying on. It's good practice to always deploy first to a testnet like Sepolia before deploying to a non-test network.

```bash
SEPOLIA_RPC_URL='https://eth-sepolia.g.alchemy.com/v2/demo'
```

## Secure key handling (default: encrypted keystore)

**Do not put private keys in `.env` for anything that holds real funds.** Import an encrypted keystore once, then pass it with `--account`:

```bash
cast wallet import deployer --interactive
forge script script/DeployCounter.s.sol --account deployer --rpc-url sepolia --broadcast --verify
```

`cast wallet import` stores the key encrypted on disk under Foundry's keystore directory. `--account deployer` unlocks it for that run (you will be prompted for the password). Scripts in this template call `vm.startBroadcast()` with no key when `DEPLOYER_PRIVATE_KEY` is unset, so the CLI account is what signs.

Deploy scripts also write the resulting address to `deployments/<chainid>.json` so later runs do not depend only on `broadcast/` logs.

Demo contracts under `examples/` use the same helpers via `script/examples/` and need `FOUNDRY_PROFILE=examples` (or `just examples-build`).

### CI / automation only: environment private key

Headless pipelines that cannot unlock a keystore may set `DEPLOYER_PRIVATE_KEY` instead. Treat that as a CI secret, never as the default local workflow:

```bash
export DEPLOYER_PRIVATE_KEY='<ci_deployer_key>'
forge script script/DeployCounter.s.sol --rpc-url sepolia --broadcast --verify
```

⚠️ **Follow proper `.env` and `.gitignore` practices. Never commit a real private key.**

## Deployment Scripts

Deployments are handled through script files, written in Solidity and using the naming convention `Contract.s.sol`. Shared broadcast, CREATE2, and deployment-record helpers live in `script/utils/DeployBase.s.sol` — extend that rather than reimplementing signing or JSON output.

You can run a script directly from your CLI:

```bash
forge script script/DeployCounter.s.sol --account deployer --rpc-url sepolia -vv
```

> 💡 It is best practice to keep all scripts related to a contract in a single script file, for example `MyToken` may have functions to `Deploy` and `Mint`. You can run a single function by appending the contract name like this: `forge script script/MyScript.s.sol:MyFunction`.

Unless you include the `--broadcast` argument, the script will be run in a simulated environment. If you need to run the script live, use the `--broadcast` arg.

⚠️ **Using `--broadcast` will initiate an onchain transaction, only use after thoroughly testing**

### Broadcast

```bash
forge script script/DeployCounter.s.sol --account deployer --rpc-url sepolia -vv --broadcast
```

Additional arguments can specify verbosity and verification:

```bash
forge script script/DeployCounter.s.sol --account deployer --rpc-url sepolia -vv --broadcast --verify
```

💡 **When deploying a new contract, you can use the `--verify` arg to verify the contract on deployment.**

## Contract Verification

After deployment, you can verify your contract on Etherscan using:

```bash
forge verify-contract <contract_address> <contract_path> --chain <network>
```

Make sure you have the appropriate Etherscan API key set in your environment variables or `foundry.toml`. For more information on network configuration, see the [Network Configuration](networks.md) guide.

---

**Navigation:**

- [← Back: Testing Guide](testing.md)
- [Next: Network Configuration →](networks.md)
