// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract DeployCounter is Script {
    function run() public {
        vm.broadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        Counter counter = new Counter();
        console.log("Counter deployed at:", address(counter));
    }
}
