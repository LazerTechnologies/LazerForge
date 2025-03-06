# Network Configuration

This guide explains how to configure and use different networks in your LazerForge project.

## Network Identifiers

When running commands like `forge verify-contract` (or using the `--verify` flag while [deploying](deployment.md)), you can specify a network via CLI flags (e.g., `--chain sepolia` or `--fork-url <url>`) and Forge will use the corresponding endpoint from the `foundry.toml` configuration.

### RPC Endpoints

The `rpc_endpoints` block links network names (`goerli`, `mainnet`, etc.) to their RPC URLs via environment variables.

### Etherscan Configuration

The `etherscan` block in `foundry.toml` maps networks to their API keys so that when you run commands that need a block explorer—ie. contract verification—Forge will use the appropriate endpoint for that network.

**Example:**

```bash
forge verify-contract --chain ethereum <contract_address> <contract_path>
```

## Environment Variables

Make sure to set up your environment variables for the networks you plan to use. For example:

```bash
export SEPOLIA_RPC_URL='https://eth-sepolia.g.alchemy.com/v2/demo'
export ETHERSCAN_API_KEY='your-api-key'
```

⚠️ **Follow proper `.env` and `.gitignore` practices to prevent leaked keys.**

## Network-Specific Configuration

Each network can have its own configuration in `foundry.toml`. Here's an example structure:

```toml
[rpc_endpoints]
goerli = "${GOERLI_RPC_URL}"
mainnet = "${MAINNET_RPC_URL}"

[etherscan]
goerli = { key = "${ETHERSCAN_API_KEY}" }
mainnet = { key = "${ETHERSCAN_API_KEY}" }
```

---

**Navigation:**

- [← Back: Deployment Guide](deployment.md)
- [Next: Profiles →](profiles.md)
