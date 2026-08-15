// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {CREATE3Factory} from "../../examples/CREATE3Factory.sol";
import {DeployBase} from "../utils/DeployBase.s.sol";

/**
 * @title DeployCREATE3Factory
 * @notice Deploys CREATE3Factory (examples profile).
 *
 * Preferred (encrypted keystore):
 *   cast wallet import deployer --interactive
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployCREATE3Factory.s.sol \
 *     --account deployer --rpc-url sepolia --broadcast --verify
 *
 * CI / automation: set DEPLOYER_PRIVATE_KEY and omit `--account`.
 */
contract DeployCREATE3Factory is DeployBase {
    function run() public {
        _startBroadcast();
        CREATE3Factory factory = new CREATE3Factory();
        require(address(factory) != address(0), "CREATE3Factory deployment failed");
        _stopBroadcast();

        _writeDeployment("CREATE3Factory", address(factory));
        console.log("CREATE3Factory deployed at:", address(factory));
    }
}
