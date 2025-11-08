// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// minimal ERC20 interface to support transfer
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

/**
 * @title Rescue
 * @author Jon Bray <jonbray@lazertechnologies.com>
 * @notice This contract is used to withdraw funds that have been sent to an
 *         address on the wrong network by deploying deterministically.
 *         See {../script/Rescue.s.sol} for more info.
 */
contract Rescue {
    error Failed();
    error NotOwner();

    event ETHWithdrawn(address indexed recipient, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed recipient, uint256 amount);

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert NotOwner();
    }

    receive() external payable {}

    function withdrawAllETH(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent,) = recipient.call{value: balance}("");
        if (!sent) revert Failed();
        emit ETHWithdrawn(recipient, balance);
    }

    function withdrawETH(address payable recipient, uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        (bool sent,) = recipient.call{value: amount}("");
        if (!sent) revert Failed();
        emit ETHWithdrawn(recipient, amount);
    }

    function withdrawERC20(address token, address recipient, uint256 amount) external onlyOwner {
        bool sent = IERC20(token).transfer(recipient, amount);
        if (!sent) revert Failed();
        emit ERC20Withdrawn(token, recipient, amount);
    }
}
