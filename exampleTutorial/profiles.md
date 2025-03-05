# Understanding Foundry Profiles

Foundry profiles are a powerful way to manage different configurations for your smart contract development workflow. Think of them as different "modes" or "settings" that you can switch between depending on your needs.

## What are Profiles?

Profiles in Foundry are named configuration sets that you can use to:

- Optimize for different scenarios (gas, testing, deployment)
- Use different compiler settings
- Configure different testing parameters
- Set up different build environments

## Available Profiles in LazerForge

LazerForge comes with several pre-configured profiles:

### Default Profile

```bash
forge build --profile default
# or simply
forge build
```

The default profile is used when no profile is specified. It includes:

- Standard compiler settings
- Basic optimization
- Normal testing parameters

### Gas Optimization Profile

```bash
forge build --profile gas
```

Use this profile when you want to:

- Optimize your contracts for gas efficiency
- Deploy to production
- Compare gas costs between different implementations

### CI Fuzz Testing Profile

```bash
forge test --profile CI.fuzz
```

This profile is designed for CI environments with:

- Increased number of fuzz runs (1024)
- More thorough testing
- Better coverage

### Via-IR Profile

```bash
forge build --profile via_ir
```

Use this profile when:

- Working with complex contracts
- Need to use the via-IR pipeline
- Dealing with large contract sizes

### FFI Profile

```bash
forge test --profile ffi
```

For tests that require:

- Foreign Function Interface (FFI)
- External process calls
- System-level interactions

## How to Use Profiles

### 1. Using Command Line Flags

The most common way to use profiles is with the `--profile` flag:

```bash
# Build with gas optimization
forge build --profile gas

# Run tests with CI settings
forge test --profile CI.fuzz

# Deploy with via-IR
forge script script/Deploy.s.sol:DeployScript --profile via_ir
```

### 2. Using Environment Variables

You can set a profile for all commands in your current shell:

```bash
# Set profile for current shell
export FOUNDRY_PROFILE=gas

# Or for a single command
FOUNDRY_PROFILE=gas forge build
```

### 3. In Deployment Scripts

When deploying contracts:

```bash
# Deploy with gas optimization
forge script script/Deploy.s.sol:DeployScript --profile gas --rpc-url $RPC_URL

# Deploy with via-IR for complex contracts
forge script script/Deploy.s.sol:DeployScript --profile via_ir --rpc-url $RPC_URL
```

## Common Use Cases

### Development

```bash
# Normal development
forge build
forge test

# When you need gas optimization
forge build --profile gas
```

### Testing

```bash
# Quick local tests
forge test

# Thorough fuzz testing
forge test --profile CI.fuzz
```

### Deployment

```bash
# Standard deployment
forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL

# Gas-optimized deployment
forge script script/Deploy.s.sol:DeployScript --profile gas --rpc-url $RPC_URL
```

## Creating Your Own Profiles

You can add custom profiles to your `foundry.toml`:

```toml
[profile.custom]
# Your custom settings here
optimizer_runs = 200
fuzz_runs = 500
```

## Best Practices

1. **Use Appropriate Profiles**

   - Use `gas` profile for production deployments
   - Use `CI.fuzz` for thorough testing
   - Use `via_ir` for complex contracts

2. **Document Profile Usage**

   - Add comments in your `foundry.toml`
   - Document profile requirements in your README
   - Explain when to use each profile

3. **CI/CD Considerations**

   - Use `CI.fuzz` in your CI pipeline
   - Consider using different profiles for different environments

4. **Development Workflow**
   - Start with default profile for development
   - Switch to `gas` profile before deployment
   - Use `via_ir` when needed for complex contracts
