# Testing Guide

This guide covers all aspects of testing in your LazerForge project.

## Deterministic Testing

LazerForge is configured to set fixed values for block height and timestamp which ensures that tests run against a predictable blockchain state. This makes debugging easier and guarantees that time or block-dependent logic behaves reliably.

- These values are called by Anvil and when running `forge test` so make sure to update the `block_number` and `block_timestamp` values in `foundry.toml`
- Make sure the values are set for the appropriate network you're testing against!

## Running Tests

Tests are handled through test files, written in Solidity and using the naming convention `Contract.t.sol`

```shell
forge test
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
2. Group related tests using `describe` blocks
3. Use `setUp` functions to initialize common test state
4. Test both positive and negative cases
5. Use assertions to verify expected behavior
6. Test edge cases and boundary conditions

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
