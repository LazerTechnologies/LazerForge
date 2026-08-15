# LazerForge command runner. `just` (or `just --list`) prints this list.
# https://github.com/casey/just

set default-list := true

# Compile contracts
build *args:
    forge build {{args}}

# Run tests
test *args:
    forge test {{args}}

# variant:full:start

# Compile example contracts (BalanceManager, InflationToken, …)
examples-build *args:
    FOUNDRY_PROFILE=examples forge build {{args}}

# Run example tests
examples-test *args:
    FOUNDRY_PROFILE=examples forge test {{args}}

# Write gas snapshots for the example contracts
snapshot *args:
    FOUNDRY_PROFILE=examples forge snapshot {{args}}

# variant:full:end

# Format Solidity
fmt *args:
    forge fmt {{args}}

# Lint Solidity
lint *args:
    forge lint {{args}}

# Coverage summary + HTML report (needs `lcov`: `brew install lcov`)
cov:
    #!/usr/bin/env bash
    set -euo pipefail
    FOUNDRY_PROFILE=coverage forge coverage --report summary --report lcov
    genhtml lcov.info -o coverage --branch

# variant:full:start

# Regenerate a variant branch into .variant-build/ without pushing (maintainers)
variant name *args:
    tools/build-variant.sh {{name}} {{args}}

# variant:full:end

# variant:full:start

# Add a development worktree under .worktrees/
worktree branch *args:
    tools/worktree.sh add {{branch}} {{args}}

# List all worktrees
worktrees:
    tools/worktree.sh list

# Remove a development worktree under .worktrees/
worktree-rm branch:
    tools/worktree.sh remove {{branch}}

# variant:full:end
