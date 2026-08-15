// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {Counter} from "../src/Counter.sol";
import {DeployBase} from "./utils/DeployBase.s.sol";

/**
 * @title DeployCounter
 * @notice Deploys the starter Counter under `src/`.
 *
 * Preferred (encrypted keystore):
 *   cast wallet import deployer --interactive
 *   forge script script/DeployCounter.s.sol --account deployer --rpc-url sepolia --broadcast --verify
 *
 * CI / automation (plaintext key in the environment):
 *   forge script script/DeployCounter.s.sol --rpc-url sepolia --broadcast
 *   # with DEPLOYER_PRIVATE_KEY set
 *
 * Simulate without broadcasting:
 *   forge script script/DeployCounter.s.sol --sender <address> --fork-url $SEPOLIA_RPC_URL -vvvv
 */
contract DeployCounter is DeployBase {
    function run() public {
        _startBroadcast();
        Counter counter = new Counter();
        _stopBroadcast();

        _writeDeployment("Counter", address(counter));
        console.log("Counter deployed at:", address(counter));
    }
}
