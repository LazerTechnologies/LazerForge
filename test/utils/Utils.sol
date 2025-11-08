// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Utils {
    function _generatePayload(uint256 length) public pure returns (bytes memory payload) {
        payload = new bytes(length);

        for (uint256 i; i < payload.length; ++i) {
            payload[i] = bytes1(uint8(i % 256));
        }
    }

    /// @dev This is NOT cryptographically secure. Just good enough for testing.
    function _genRandomInt(uint256 min, uint256 max) internal view returns (uint256) {
        return min
            + (uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, block.number, msg.sender)))
                % (max - min + 1));
    }

    function _genBytes(uint32 length) internal pure returns (bytes memory message) {
        message = new bytes(length);

        for (uint256 i; i < length; ++i) {
            message[i] = bytes1(uint8(i % 256));
        }
    }

    function _genString(uint32 length) internal pure returns (string memory) {
        return string(_genBytes(length));
    }
}
