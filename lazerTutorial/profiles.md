# Understanding Foundry Profiles

Foundry profiles let you manage different configurations for your smart contract development workflow. Think of them like "modes" or "settings" that you can switch between depending on your needs.

## What are Profiles?

Profiles in Foundry are named configuration sets that you can use to:

- optimize for different scenarios (gas, testing, deployment)
- use different compiler settings
- configure different testing parameters
- set up different build environments

## Available Profiles in LazerForge

LazerForge comes packaged with several pre-configured profiles:

### Default Profile

```bash
FOUNDRY_PROFILE=default forge build
# or simply
forge build
```

The default profile is used when no profile is specified. It includes:

- standard compiler settings
- basic optimization
- normal testing parameters

### Gas Optimization Profile

```bash
FOUNDRY_PROFILE=gas forge build
```

Use this profile when you want to:

- optimize your contracts for gas efficiency
- deploy to production
- compare gas costs between different implementations

### CI Fuzz Testing Profile

```bash
FOUNDRY_PROFILE=ci forge test
```

This profile is designed for CI environments with:

- increased number of fuzz runs (1024)
- more thorough testing

### Via-IR Profile

```bash
FOUNDRY_PROFILE=via_ir forge build
```

Use this profile when:

- working with complex contracts
- need to use the via-IR pipeline
- dealing with large contract sizes

### Coverage Profile

```bash
FOUNDRY_PROFILE=coverage forge coverage
# or
just cov
```

Use this profile when generating coverage reports. It turns the optimizer off because the default `optimizer_runs = 9_999_999` destroys the source maps `forge coverage` needs, and it keeps fuzz runs small so reports stay fast. `just cov` selects it automatically and writes the HTML report. The CI coverage job sets `FOUNDRY_PROFILE=coverage` for you.

### FFI Profile

```bash
FOUNDRY_PROFILE=ffi forge test
```

For tests that require:

- Foreign Function Interface (FFI)
- external process calls
- system-level interactions

### Examples Profile

```bash
FOUNDRY_PROFILE=examples forge build
FOUNDRY_PROFILE=examples forge test
```

Builds and tests the demo contracts under `examples/` (`BalanceManager`, `InflationToken`, `CREATE3Factory`, …). The default profile only compiles `src/` so a fresh template build is your code, not the demos.

## How to Use Profiles

### 1. Per-command

`forge` has no `--profile` flag. Select a profile by setting the
`FOUNDRY_PROFILE` environment variable for a single command:

```bash
# Build with gas optimization
FOUNDRY_PROFILE=gas forge build

# Run tests with CI settings
FOUNDRY_PROFILE=ci forge test

# Generate a coverage report
FOUNDRY_PROFILE=coverage forge coverage

# Deploy with via-IR
FOUNDRY_PROFILE=via_ir forge script script/DeployCounter.s.sol:DeployCounter

# Build / test the demo contracts
FOUNDRY_PROFILE=examples forge build
FOUNDRY_PROFILE=examples forge script script/examples/DeployBalanceManager.s.sol:DeployBalanceManager
```

### 2. For an entire shell session

You can set a profile for all commands in your current shell:

```bash
# Set profile for current shell
export FOUNDRY_PROFILE=gas
```

### 3. In Deployment Scripts

When deploying contracts:

```bash
# Deploy with gas optimization
FOUNDRY_PROFILE=gas forge script script/DeployCounter.s.sol:DeployCounter --rpc-url $RPC_URL

# Deploy with via-IR for complex contracts
FOUNDRY_PROFILE=via_ir forge script script/DeployCounter.s.sol:DeployCounter --rpc-url $RPC_URL
```

## Common Use Cases

### Development

```bash
# Normal development
forge build
forge test

# When you need gas optimization
FOUNDRY_PROFILE=gas forge build
```

### Testing

```bash
# Quick local tests
forge test

# Thorough fuzz testing
FOUNDRY_PROFILE=ci forge test

# Coverage report (optimizer off)
FOUNDRY_PROFILE=coverage forge coverage
```

### Deployment

```bash
# Standard deployment
forge script script/DeployCounter.s.sol:DeployCounter --rpc-url $RPC_URL

# Gas-optimized deployment
FOUNDRY_PROFILE=gas forge script script/DeployCounter.s.sol:DeployCounter --rpc-url $RPC_URL
```

## Creating Your Own Profiles

You can add custom profiles to your `foundry.toml`:

```toml
[profile.custom]
# Your custom settings here
optimizer_runs = 200
fuzz_runs = 500
```

> Any settings not specified within a profile will use the `default` settings. Make sure to override settings from `profile.default` with a custom profile when needed.

## Best Practices

1. **Use Appropriate Profiles**

   - Use `gas` profile for production deployments
   - Use `CI.fuzz` for thorough testing
   - Use `coverage` for coverage reports
   - Use `via_ir` for complex contracts

2. **Document Profile Usage**

   - Add comments in your `foundry.toml`
   - Document profile requirements in your README

3. **CI/CD Considerations**

   - Use `CI.fuzz` in your CI pipeline
   - Consider using different profiles for different environments

4. **Development Workflow**
   - Start with default profile for development
   - Switch to `gas` profile before deployment
   - Use `via_ir` when needed for complex contracts

## Profile Inheritance

Profiles can inherit from other profiles using the `inherits` field. This allows you to build upon existing configurations while adding or overriding specific settings.

```toml
[profile.production]
inherits = "default"
optimizer = true
optimizer_runs = 1000
```

---

**Navigation:**

- [← Back: Network Configuration](networks.md)
- [Next: Appendix →](Appendix.md)
