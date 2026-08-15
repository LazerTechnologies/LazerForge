// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../../examples/InflationToken.sol";

/**
 * @title DeployInflationToken
 * @notice This script deploys InflationToken. Simulate running it by entering
 *         `forge script script/examples/DeployInflationToken.s.sol --sender <the_caller_address>
 *         --fork-url $SEPOLIA_RPC_URL -vvvv` in the terminal. To run it for
 *         real, change it to `forge script script/examples/DeployInflationToken.s.sol
 *         --fork-url $SEPOLIA_RPC_URL --broadcast`.
 *         Requires FOUNDRY_PROFILE=examples.
 */
contract DeployInflationToken is Script {
    function run() public {
        vm.broadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        InflationToken inflationToken = new InflationToken();
        console.log("InflationToken deployed at:", address(inflationToken));
    }
}
