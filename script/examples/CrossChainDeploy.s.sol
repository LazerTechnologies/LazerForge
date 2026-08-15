// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {LibString} from "solady/utils/LibString.sol";
import {BalanceManager} from "../../examples/BalanceManager.sol";
import {DeployBase} from "../utils/DeployBase.s.sol";

/**
 * @title CrossChainDeployScript
 * @notice Deploys BalanceManager to the same CREATE2 address on every chain that
 *         hosts 0age's ImmutableCreate2Factory (examples profile).
 *
 * Preferred (encrypted keystore):
 *   cast wallet import deployer --interactive
 *   FOUNDRY_PROFILE=examples forge script script/examples/CrossChainDeploy.s.sol \
 *     --tc CrossChainDeployScript --account deployer --rpc-url sepolia --broadcast
 *
 * Simulate:
 *   FOUNDRY_PROFILE=examples forge script script/examples/CrossChainDeploy.s.sol \
 *     --tc CrossChainDeployScript --sender <address> --fork-url $SEPOLIA_RPC_URL -vvvv
 */
contract CrossChainDeployScript is DeployBase {
    mapping(uint256 => string) private chainToBlockExplorer;

    function setUp() public {
        _setPrefixValues();
    }

    function run() public {
        _startBroadcast();
        // Bake the broadcaster into init code so Ownable gets a non-zero owner
        // and the CREATE2 address stays stable across chains for a given salt.
        address deployed = _deploy(bytes.concat(type(BalanceManager).creationCode, abi.encode(deployer)));
        _stopBroadcast();

        _writeDeployment("BalanceManager", deployed);
    }

    function _deploy(bytes memory initCode) internal returns (address) {
        return _deploy(DEFAULT_SALT, initCode);
    }

    function _deploy(bytes32 salt, bytes memory initCode) internal returns (address) {
        bytes32 initCodeHash = keccak256(initCode);
        (address deploymentAddress, bool deployedNow) = _deployCreate2(salt, initCode);

        if (!deployedNow) {
            console.log(
                _pad("Found", 10),
                _pad(LibString.toHexString(deploymentAddress), 43),
                LibString.toHexString(uint256(initCodeHash))
            );
            return deploymentAddress;
        }

        string memory bold = "\x1b[1m%s\x1b[0m";
        console.log(
            bold, _chainIsSupportedByABlockExplorer() ? "Deployed BalanceManager at:" : "Deployed BalanceManager!"
        );
        console.log(bold, _getBlockExplorerLog(deploymentAddress));
        console.log("");
        console.log(bold, "Initialization code hash:", LibString.toHexString(uint256(initCodeHash)));
        return deploymentAddress;
    }

    function _pad(string memory name, uint256 n) internal pure returns (string memory) {
        string memory padded = name;
        while (bytes(padded).length < n) {
            padded = string.concat(padded, " ");
        }
        return padded;
    }

    function _getBlockExplorerLog(address targetContract) internal view returns (string memory) {
        string memory blockExplorerString = string.concat(
            "View the contract on a block explorer: ", chainToBlockExplorer[block.chainid], vm.toString(targetContract)
        );
        return _chainIsSupportedByABlockExplorer() ? blockExplorerString : "";
    }

    function _chainIsSupportedByABlockExplorer() internal view returns (bool) {
        return bytes(chainToBlockExplorer[block.chainid]).length != 0;
    }

    function _setPrefixValues() internal {
        chainToBlockExplorer[1] = "https://etherscan.io/address/";
        chainToBlockExplorer[11155111] = "https://sepolia.etherscan.io/address/";
        chainToBlockExplorer[137] = "https://polygonscan.com/address/";
        chainToBlockExplorer[43114] = "https://snowtrace.io/address/";
        chainToBlockExplorer[100] = "https://gnosisscan.io/address/";
        chainToBlockExplorer[10200] = "https://gnosis-chiado.blockscout.com/address/";
        chainToBlockExplorer[42161] = "https://arbiscan.io/address/";
        chainToBlockExplorer[42170] = "https://nova.arbiscan.io/address/";
        chainToBlockExplorer[10] = "https://optimistic.etherscan.io/address/";
        chainToBlockExplorer[8453] = "https://basescan.org/address/";
        chainToBlockExplorer[84532] = "https://sepolia.basescan.org/address/";
        chainToBlockExplorer[7777777] = "https://explorer.zora.energy/address/";
        chainToBlockExplorer[999] = "https://testnet.explorer.zora.energy/address/";
    }
}
