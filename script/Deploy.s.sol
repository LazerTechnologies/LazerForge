// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BalanceManager.sol";

/**
 * @title DeployScript
 * @notice This script deploys BalanceManager. Simulate running it by entering
 *         `forge script script/Deploy.s.sol --sender <the_caller_address>
 *         --fork-url $GOERLI_RPC_URL -vvvv` in the terminal. To run it for
 *         real, change it to `forge script script/Deploy.s.sol
 *         --fork-url $GOERLI_RPC_URL --broadcast`.
 */
contract DeployScript is Script {
  function run() public {
    string memory mnemonic = vm.envString("MNEMONIC");
    uint256 privateKey = vm.deriveKey(mnemonic, 0); // Standard HD path
    vm.startBroadcast(privateKey); 
    BalanceManager balanceManager = new BalanceManager(address(0));
    console.log("BalanceManager deployed at:", address(balanceManager));
  }
}
