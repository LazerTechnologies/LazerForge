// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

using SafeERC20 for IERC20;

/**
 * @title InflationToken
 * @author [Jon Bray](https://warpcast.com/jonbray.eth)
 * @notice This is an ERC20 token with an inflation mechanic that allows the
 *         token to be minted at a rate of 5% per year, enforcing a 365 day
 *         period between mints. The 5% rate is applied to the initial supply,
 *         not the total supply.
 */
contract InflationToken is ERC20, ERC20Burnable, Ownable {
    string public constant TOKEN_NAME = "InflationToken";
    string public constant TOKEN_SYMBOL = "INFLA";
    uint256 public constant TOKEN_INITIAL_SUPPLY = 1_000_000_000;
    uint256 public constant MINT_CAP = 50_000_000;
    uint32 public constant MINIMUM_TIME_BETWEEN_MINTS = 365 days;

    uint256 public mintingAllowedAfter;
    uint256 public amountMintedInCurrentYear;

    error MintingDateNotReached();
    error CannotMintToBlockedAddress();
    error MintCapExceeded();

    event TokensRecovered(address indexed token, address indexed recipient, uint256 amount);
    event TokensMinted(address indexed recipient, uint256 amount);

    constructor() ERC20(TOKEN_NAME, TOKEN_SYMBOL) Ownable() {
        _mint(msg.sender, TOKEN_INITIAL_SUPPLY * 10 ** decimals());
        mintingAllowedAfter = block.timestamp + MINIMUM_TIME_BETWEEN_MINTS;
    }

    /**
     * @dev mint new tokens for inflation mechanic
     * @dev inflation is fixed 5% per year max based on initial supply
     * @param to The address of the target account
     */
    function mint(address to) external onlyOwner {
        if (block.timestamp < mintingAllowedAfter) {
            revert MintingDateNotReached();
        }
        if (to == address(0) || to == address(this)) {
            revert CannotMintToBlockedAddress();
        }

        // enforce 365 day period between mints
        mintingAllowedAfter = block.timestamp + MINIMUM_TIME_BETWEEN_MINTS;
        _mint(to, MINT_CAP);
        emit TokensMinted(to, MINT_CAP);
    }

    /**
     * @dev recover tokens sent to the contract address
     * @param token the address of the token to recover
     * @param amount the amount of tokens to recover
     * @param to the address to send the recovered tokens to
     */
    function recoverTokens(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).safeTransfer(to, amount);
        emit TokensRecovered(token, to, amount);
    }
}
