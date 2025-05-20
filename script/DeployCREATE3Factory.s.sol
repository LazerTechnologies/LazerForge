// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CREATE3Factory} from "../src/CREATE3Factory.sol";

import {Utils} from "../script/utils/Utils.sol";

contract DeployCREATE3Factory is Utils {
    CREATE3Factory factory;

    address deployer;

    function run() public {
        uint256 privateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        require(privateKey != 0, "DEPLOYER_PRIVATE_KEY not set");

        deployer = vm.addr(privateKey);
        vm.startBroadcast(privateKey);

        factory = new CREATE3Factory();
        require(address(factory) != address(0), "CREATE3Factory deployment failed");

        vm.stopBroadcast();

        _serializeDeploymentData();
    }

    function _serializeDeploymentData() internal {
        string memory parent_object = "parent object";
        string memory addresses = "addresses";
        string memory constructorArgs = "constructorArgs";

        string memory addressesOutput;
        addressesOutput = vm.serializeAddress(addresses, "deployer", deployer);
        addressesOutput = vm.serializeAddress(addresses, "implementation", address(factory));

        string memory constructorArgsOutput;

        string memory finalJson;
        finalJson = vm.serializeString(parent_object, addresses, addressesOutput);
        finalJson = vm.serializeString(parent_object, constructorArgs, constructorArgsOutput);
        finalJson = vm.serializeUint(parent_object, "deploymentBlock", block.number);

        writeOutput(finalJson, "CREATE3Factory");
    }
}
