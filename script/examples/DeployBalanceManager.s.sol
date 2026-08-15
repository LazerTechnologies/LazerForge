// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {BalanceManager} from "../../examples/BalanceManager.sol";
import {DeployBase} from "../utils/DeployBase.s.sol";

/**
 * @title DeployBalanceManager
 * @notice Deploys BalanceManager with the broadcaster as `initialOwner` (examples profile).
 *
 * Preferred (encrypted keystore):
 *   cast wallet import deployer --interactive
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployBalanceManager.s.sol \
 *     --account deployer --rpc-url sepolia --broadcast --verify
 *
 * CI / automation (plaintext key in the environment):
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployBalanceManager.s.sol \
 *     --rpc-url sepolia --broadcast
 *   # with DEPLOYER_PRIVATE_KEY set
 *
 * Simulate without broadcasting:
 *   FOUNDRY_PROFILE=examples forge script script/examples/DeployBalanceManager.s.sol \
 *     --sender <address> --fork-url $SEPOLIA_RPC_URL -vvvv
 */
contract DeployBalanceManager is DeployBase {
    function run() public {
        _startBroadcast();
        // OpenZeppelin's Ownable rejects address(0); pass the broadcasting account.
        BalanceManager balanceManager = new BalanceManager(deployer);
        _stopBroadcast();

        _writeDeployment("BalanceManager", address(balanceManager));
        console.log("BalanceManager deployed at:", address(balanceManager));
    }
}
