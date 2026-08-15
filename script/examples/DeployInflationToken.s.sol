// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {InflationToken} from "../../examples/InflationToken.sol";
import {DeployBase} from "../utils/DeployBase.s.sol";

/**
 * @title DeployInflationToken
 * @notice Deploys InflationToken (examples profile).
 *
 * Preferred (encrypted keystore):
 *   cast wallet import deployer --interactive
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployInflationToken.s.sol \
 *     --account deployer --rpc-url sepolia --broadcast --verify
 *
 * CI / automation (plaintext key in the environment):
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployInflationToken.s.sol \
 *     --rpc-url sepolia --broadcast
 *   # with DEPLOYER_PRIVATE_KEY set
 *
 * Simulate without broadcasting:
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployInflationToken.s.sol \
 *     --sender <address> --fork-url $SEPOLIA_RPC_URL -vvvv
 */
contract DeployInflationToken is DeployBase {
    function run() public {
        _startBroadcast();
        InflationToken inflationToken = new InflationToken();
        _stopBroadcast();

        _writeDeployment("InflationToken", address(inflationToken));
        console.log("InflationToken deployed at:", address(inflationToken));
    }
}
