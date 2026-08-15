# LazerForge command runner. `just` (or `just --list`) prints this list.
# https://github.com/casey/just

set default-list := true

# Compile contracts
build *args:
    forge build {{args}}

# Run tests
test *args:
    forge test {{args}}

# Format Solidity
fmt *args:
    forge fmt {{args}}

# Lint Solidity
lint *args:
    forge lint {{args}}

# Write gas snapshots
snapshot *args:
    forge snapshot {{args}}

# Coverage summary + HTML report (needs `lcov`: `brew install lcov`)
cov:
    #!/usr/bin/env bash
    set -euo pipefail
    FOUNDRY_PROFILE=coverage forge coverage --report summary --report lcov
    genhtml lcov.info -o coverage --branch

