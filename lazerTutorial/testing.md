# Testing Guide

This guide covers testing smart contracts in your LazerForge project.

## Deterministic Testing

LazerForge is configured to set fixed values for block height and timestamp which ensures that tests run against a predictable blockchain state. This makes debugging easier and guarantees that time or block-dependent logic behaves reliably.

- These values are called by Anvil and when running `forge test` so make sure to update the `block_number` and `block_timestamp` values in `foundry.toml`
  - Setting these variables correctly is vital when testing against contracts that are live. For example, if the block height is set to some time in August 2024 but you're testing composability with a contract first deployed in October 2024, the test will fail.
- Make sure the values are set for the appropriate network you're testing against!

## Running Tests

Tests are handled through test files, written in Solidity and using the naming convention `Contract.t.sol`.

You can run all of your test files at once:

```shell
forge test
```

or specify a certain file, and optionally test:

```bash
forge test --match-path test/Contract.t.sol --match-test test_Deposit
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

## Writing Tests

Tests in LazerForge follow best practices for smart contract testing:

1. Use descriptive test names that explain what is being tested
2. Use `setUp` functions to initialize common test state
   - anything defined in `setUp()` is used for the entirety of that test contract
3. Test both positive and negative cases
4. Use assertions to verify expected behavior
5. Test edge cases and boundary conditions

Example test structure:

```solidity
contract MyContractTest is Test {
    function setUp() public {
        // Initialize test state
    }

    function testPositiveCase() public {
        // Test successful execution
    }

    function testNegativeCase() public {
        // Test failure cases
    }
}
```

---

**Navigation:**

- [← Back: Setup Guide](setup.md)
- [Next: Deployment Guide →](deployment.md)
