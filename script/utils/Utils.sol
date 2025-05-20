// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract Utils is Script {
    uint256 constant CHAIN_ID_ANVIL_LOCALNET = 31_337;

    string constant OUTPUT_ANVIL_LOCALNET = "anvil_localnet";
    string constant OUTPUT_UNKNOWN = "unknown";

    function readInput(string memory inputFileName) internal view returns (string memory) {
        string memory file = getInputPath(inputFileName);
        return vm.readFile(file);
    }

    function getInputPath(string memory inputFileName) internal view returns (string memory) {
        string memory inputDir = string.concat(vm.projectRoot(), "/deployments/");
        string memory file = string.concat(inputFileName, ".json");
        return string.concat(inputDir, file);
    }

    function readOutput(string memory outputFileName) internal view returns (string memory) {
        string memory file = getOutputPath(outputFileName);
        return vm.readFile(file);
    }

    function writeOutput(string memory outputJson, string memory outputFileName) internal {
        string memory outputFilePath = getOutputPath(outputFileName);
        vm.writeJson(outputJson, outputFilePath);
    }

    function getOutputPath(string memory outputFileName) internal view returns (string memory) {
        string memory outputDir = string.concat(vm.projectRoot(), "/deployments/");
        string memory outputFilePath = string.concat(outputDir, outputFileName, ".json");
        return outputFilePath;
    }
}
