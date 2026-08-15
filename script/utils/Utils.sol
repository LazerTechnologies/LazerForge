// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployBase} from "./DeployBase.s.sol";

/**
 * @title Utils
 * @notice Thin helpers on top of {DeployBase}. Prefer `_writeDeployment` for new
 *         scripts — these named-file APIs now resolve to `deployments/<chainid>.json`.
 */
abstract contract Utils is DeployBase {
    uint256 constant CHAIN_ID_ANVIL_LOCALNET = 31_337;

    string constant OUTPUT_ANVIL_LOCALNET = "anvil_localnet";
    string constant OUTPUT_UNKNOWN = "unknown";

    function readInput(string memory inputFileName) internal view returns (string memory) {
        return vm.readFile(getInputPath(inputFileName));
    }

    function getInputPath(string memory inputFileName) internal view returns (string memory) {
        return string.concat(_deploymentsDir(), inputFileName, ".json");
    }

    function readOutput(string memory) internal view returns (string memory) {
        return vm.readFile(_deploymentsPath());
    }

    function writeOutput(string memory outputJson, string memory) internal {
        _ensureDeploymentsDir();
        vm.writeJson(outputJson, _deploymentsPath());
    }

    function getOutputPath(string memory) internal view returns (string memory) {
        return _deploymentsPath();
    }
}
