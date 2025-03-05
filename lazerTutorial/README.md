# LazerForge Tutorial

LazerForge is a Foundry template designed to get Lazerites up and running quickly without having to configure Foundry for every projects. It provides a comprehensive development environment with pre-configured settings, essential dependencies, and best practices for smart contract development.

This tutorial directory contains example contracts, tests, and scripts that showcase different types of smart contracts and common patterns. These examples serve as reference implementations and learning resources for various smart contract concepts and best practices.

## Example Contracts

| Contract         | Description                                                                                           | Key Concepts                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `InflationToken` | ERC20 token with inflation mechanism                                                                  | - Access Control<br>- Time-based Operations<br>- Token Economics       |
| `BalanceManager` | Contract for managing token balances                                                                  | - Admin Management<br>- Balance Tracking<br>- Contract Interactions    |
| `Rescue`         | Utility for recovering funds that were accidentally sent to a contract address on a different network | - Deterministic Deployment<br>- ETH/ERC20 Recovery<br>- Access Control |

## Getting Started

1. [Setup Guide](setup.md) - Initial project setup and configuration
2. [Testing Guide](testing.md) - Writing and running tests
3. [Deployment Guide](deployment.md) - Deploying contracts
4. [Network Configuration](networks.md) - Setting up networks and RPC endpoints
5. [Profiles](profiles.md) - Using different Foundry profiles
6. [Appendix](Appendix.md) - Additional resources and reference materials

## Useful Resources

- [Foundry Book](https://book.getfoundry.sh/) - Comprehensive guide to using Foundry
- [Solidity Documentation](https://docs.soliditylang.org/) - Official Solidity language documentation
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts) - Battle-tested smart contract libraries
- [Solady Contracts](https://github.com/vectorized/solady) - Gas-optimized Solidity snippets
- [Ethereum Development Documentation](https://ethereum.org/en/developers/docs/) - General Ethereum development resources
