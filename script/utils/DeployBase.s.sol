// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

/// @dev 0age's ImmutableCreate2Factory, deployed on every major EVM chain.
interface ImmutableCreate2Factory {
    function hasBeenDeployed(address deploymentAddress) external view returns (bool);

    function findCreate2Address(bytes32 salt, bytes calldata initializationCode)
        external
        view
        returns (address deploymentAddress);

    function safeCreate2(bytes32 salt, bytes calldata initializationCode)
        external
        payable
        returns (address deploymentAddress);
}

/**
 * @title DeployBase
 * @notice Shared deploy plumbing for LazerForge scripts.
 *
 * Prefer an encrypted keystore account at the CLI:
 *
 *   cast wallet import deployer --interactive
 *   forge script script/DeployCounter.s.sol --account deployer --rpc-url base --broadcast
 *
 * `DEPLOYER_PRIVATE_KEY` remains supported for CI / automation only.
 *
 * Successful broadcasts append addresses to `deployments/<chainid>.json`.
 */
abstract contract DeployBase is Script {
    ImmutableCreate2Factory internal constant IMMUTABLE_CREATE2_FACTORY =
        ImmutableCreate2Factory(0x0000000000FFe8B47B3e2130213B802212439497);

    bytes32 internal constant DEFAULT_SALT = bytes32(uint256(0x1));

    /// @dev Broadcaster resolved by `_startBroadcast` / `_loadDeployer`.
    address internal deployer;

    // -------------------------------------------------------------------------
    // Broadcast
    // -------------------------------------------------------------------------

    /// @dev Resolve the deployer without starting a broadcast.
    ///      Keystore / `--account` path: uses the active script sender.
    ///      CI path: derives the address from `DEPLOYER_PRIVATE_KEY`.
    function _loadDeployer() internal {
        if (vm.envExists("DEPLOYER_PRIVATE_KEY")) {
            uint256 privateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
            require(privateKey != 0, "DEPLOYER_PRIVATE_KEY is zero");
            deployer = vm.addr(privateKey);
            return;
        }

        (, address msgSender,) = vm.readCallers();
        require(msgSender != address(0), "no deployer: use --account or set DEPLOYER_PRIVATE_KEY");
        deployer = msgSender;
    }

    /// @dev Start broadcasting as the keystore account, or the CI private key.
    function _startBroadcast() internal {
        _loadDeployer();
        if (vm.envExists("DEPLOYER_PRIVATE_KEY")) {
            vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        } else {
            vm.startBroadcast();
        }
    }

    function _stopBroadcast() internal {
        vm.stopBroadcast();
    }

    // -------------------------------------------------------------------------
    // CREATE2
    // -------------------------------------------------------------------------

    /// @dev Deterministic salt from a human-readable label.
    function _salt(string memory label) internal pure returns (bytes32) {
        return keccak256(bytes(label));
    }

    /// @dev Optional `CREATE2_SALT` env override; otherwise `_salt(label)`.
    function _saltOrDefault(string memory label) internal view returns (bytes32) {
        if (vm.envExists("CREATE2_SALT")) {
            return vm.envBytes32("CREATE2_SALT");
        }
        return _salt(label);
    }

    function _predictCreate2(bytes32 salt, bytes memory initCode) internal pure returns (address) {
        return address(
            uint160(
                uint256(
                    keccak256(abi.encodePacked(hex"ff", address(IMMUTABLE_CREATE2_FACTORY), salt, keccak256(initCode)))
                )
            )
        );
    }

    /// @return deployment The CREATE2 address (existing or newly deployed).
    /// @return deployedNow True when this call submitted `safeCreate2`.
    function _deployCreate2(bytes32 salt, bytes memory initCode)
        internal
        returns (address deployment, bool deployedNow)
    {
        deployment = _predictCreate2(salt, initCode);
        if (IMMUTABLE_CREATE2_FACTORY.hasBeenDeployed(deployment)) {
            return (deployment, false);
        }
        deployment = IMMUTABLE_CREATE2_FACTORY.safeCreate2(salt, initCode);
        return (deployment, true);
    }

    // -------------------------------------------------------------------------
    // Deployment records — deployments/<chainid>.json
    // -------------------------------------------------------------------------

    function _deploymentsDir() internal view returns (string memory) {
        return string.concat(vm.projectRoot(), "/deployments/");
    }

    function _deploymentsPath() internal view returns (string memory) {
        return string.concat(_deploymentsDir(), vm.toString(block.chainid), ".json");
    }

    function _ensureDeploymentsDir() internal {
        string memory dir = _deploymentsDir();
        if (!vm.exists(dir)) {
            vm.createDir(dir, true);
        }
    }

    /// @dev Merge `name -> addr` into `deployments/<chainid>.json`.
    function _writeDeployment(string memory name, address addr) internal {
        _ensureDeploymentsDir();
        string memory path = _deploymentsPath();

        if (!vm.exists(path)) {
            vm.writeFile(path, "{}\n");
        }

        // `writeJson` with a value key updates in place without clobbering siblings.
        string memory value = string.concat("\"", vm.toString(addr), "\"");
        vm.writeJson(value, path, string.concat(".", name));
    }

    /// @dev Read a previously recorded address. Reverts if the file or key is missing.
    function _readDeployment(string memory name) internal view returns (address) {
        return vm.parseJsonAddress(vm.readFile(_deploymentsPath()), string.concat(".", name));
    }
}
