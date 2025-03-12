#!/bin/bash

set -e
source .env
anvil --fork-url $ETH_RPC_URL --mnemonic "${MNEMONIC}"
