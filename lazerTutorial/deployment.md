# Deployment Guide

This guide covers how to deploy contracts using LazerForge.

## Quick Deploy Guide

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

## Deployment Scripts

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

Additional arguments can specify the chain and verbosity of the script

```bash
forge script script/MyContract.s.sol:MyContractScript --rpc-url <your_rpc_url> --private-key <your_private_key> --chain-id 1 -vv
```

## Secure Private Key Handling

You can pass a private key directly into script functions to prevent exposing it in the command line (recommended).

⚠️ **NEVER place your private key inside of a script, always use secure environment variables!**

```js
function run() public {
    vm.startBroadcast(vm.envUint('PRIVATE_KEY'));
    // rest of your code...
}
```

Then run the `forge script` command without the private key arg.

💡 **When deploying a new contract, you can use the `--verify` arg to verify the contract on deployment.**

## Contract Verification

After deployment, you can verify your contract on Etherscan using:

```bash
forge verify-contract <contract_address> <contract_path> --chain <network>
```

Make sure you have the appropriate Etherscan API key set in your environment variables or `foundry.toml`. For more information on network configuration, see the [Network Configuration](networks.md) guide.
