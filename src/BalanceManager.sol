// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Balance Manager
 * @author [Jon Bray](https://warpcast.com/jonbray.eth)
 * @notice Only admin can update user balance mappings.
 * @notice Users can claim their balance of any token at any time.
 */
contract BalanceManager is Ownable, ReentrancyGuard {
    mapping(address => bool) public admins;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => uint256) public totalBalances;
    mapping(address => address[]) public walletTokens;
    mapping(address => address[]) public tokenWallets;
    address[] public allTokens;
    address[] public allAdmins;

    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);
    event BalanceSet(address indexed user, address indexed token, uint256 balance);
    event BalanceIncreased(address indexed user, address indexed token, uint256 amount);
    event BalanceReduced(address indexed user, address indexed token, uint256 amount);
    event BalanceClaimed(address indexed user, address indexed token, uint256 amount);
    event Funded(address indexed token, uint256 amount);
    event TokensWithdrawn(address indexed token, uint256 amount, address indexed to);

    error ContractCannotBeTheUser();

    modifier onlyAdmin() {
        require(admins[msg.sender], "Caller is not an admin");
        _;
    }

    modifier notContract(address user) {
        _notContract(user);
        _;
    }

    function _notContract(address user) internal view {
        if (user == address(this)) revert ContractCannotBeTheUser();
    }

    constructor(address initialOwner) Ownable() {}

    function addAdmin(address admin) external onlyOwner {
        admins[admin] = true;
        allAdmins.push(admin);
        emit AdminAdded(admin);
    }

    function removeAdmin(address admin) external onlyOwner {
        admins[admin] = false;
        emit AdminRemoved(admin);
    }

    /**
     * @dev Sets the balance of `user` for `token`
     * @dev only admin can set balance
     * @param amount The amount to set
     */
    function setBalance(address user, address token, uint256 amount) external onlyAdmin notContract(user) {
        require(user != address(0), "Invalid user address");
        require(token != address(0), "Invalid token address");

        uint256 currentBalance = balances[user][token];
        if (currentBalance == 0 && amount > 0) {
            walletTokens[user].push(token);
            tokenWallets[token].push(user);
            if (totalBalances[token] == 0) {
                allTokens.push(token);
            }
        }

        if (amount > currentBalance) {
            totalBalances[token] += (amount - currentBalance);
        } else {
            totalBalances[token] -= (currentBalance - amount);
        }

        balances[user][token] = amount;
        emit BalanceSet(user, token, amount);
    }

    function increaseBalance(address user, address token, uint256 amount) external onlyAdmin notContract(user) {
        require(user != address(0), "Invalid user address");
        require(token != address(0), "Invalid token address");

        if (balances[user][token] == 0 && amount > 0) {
            walletTokens[user].push(token);
            tokenWallets[token].push(user);
            if (totalBalances[token] == 0) {
                allTokens.push(token);
            }
        }

        balances[user][token] += amount;
        totalBalances[token] += amount;
        emit BalanceIncreased(user, token, amount);
    }

    function reduceBalance(address user, address token, uint256 amount) external onlyAdmin notContract(user) {
        require(user != address(0), "Invalid user address");
        require(token != address(0), "Invalid token address");
        require(balances[user][token] >= amount, "Insufficient balance");

        balances[user][token] -= amount;
        totalBalances[token] -= amount;
        emit BalanceReduced(user, token, amount);
    }

    /**
     * @dev allow any user to fund the contract
     * @dev balance must still be set by admin
     */
    function fund(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than zero");
        if (totalBalances[token] == 0) {
            allTokens.push(token);
        }
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Funded(token, amount);
    }

    /**
     * @dev allows a user to claim their balance of a certain token
     * @param token token to claim balance of
     */
    function claim(address token) public notContract(msg.sender) nonReentrant {
        require(token != address(0), "Invalid token address");
        uint256 balance = balances[msg.sender][token];
        require(balance > 0, "No balance available");

        balances[msg.sender][token] = 0;
        totalBalances[token] -= balance;
        emit BalanceClaimed(msg.sender, token, balance);
        IERC20(token).transfer(msg.sender, balance);
    }

    /**
     * @dev allows a user to claim their balance of all tokens
     */
    function claimAll() external notContract(msg.sender) nonReentrant {
        uint256 length = walletTokens[msg.sender].length;
        require(length > 0, "No balances available to claim");

        for (uint256 i = 0; i < length; i++) {
            address token = walletTokens[msg.sender][i];
            uint256 balance = balances[msg.sender][token];
            if (balance > 0) {
                balances[msg.sender][token] = 0;
                totalBalances[token] -= balance;
                emit BalanceClaimed(msg.sender, token, balance);
                IERC20(token).transfer(msg.sender, balance);
            }
        }
    }

    /**
     * @dev allows admin to withdraw excess tokens
     * @dev only tokens not assigned to a balance can be withdrawn
     * @param token address of target token
     * @param amount amount of token to withdraw
     * @param to address of recipient account
     */
    function withdrawExcessTokens(address token, uint256 amount, address to) external onlyAdmin {
        require(token != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");

        uint256 availableAmount = IERC20(token).balanceOf(address(this)) - totalBalances[token];
        require(amount <= availableAmount, "Insufficient excess token balance");

        IERC20(token).transfer(to, amount);
        emit TokensWithdrawn(token, amount, to);
    }

    /**
     * Getter Methods
     */
    function getAllAdmins() external view returns (address[] memory) {
        return allAdmins;
    }

    function isAdmin(address account) external view returns (bool) {
        return admins[account];
    }

    // get balance for a specific (wallet, token)
    function getBalance(address wallet, address token) external view returns (uint256) {
        return balances[wallet][token];
    }

    // get all [token, balance] for a specific wallet
    function getBalancesForWallet(address wallet) external view returns (address[] memory, uint256[] memory) {
        uint256 length = walletTokens[wallet].length;
        address[] memory tokens = new address[](length);
        uint256[] memory balanceValues = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokens[i] = walletTokens[wallet][i];
            balanceValues[i] = balances[wallet][tokens[i]];
        }
        return (tokens, balanceValues);
    }

    // get all [wallet, balance] for a specific token
    function getBalancesForToken(address token) external view returns (address[] memory, uint256[] memory) {
        uint256 length = tokenWallets[token].length;
        address[] memory wallets = new address[](length);
        uint256[] memory balanceValues = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            wallets[i] = tokenWallets[token][i];
            balanceValues[i] = balances[wallets[i]][token];
        }
        return (wallets, balanceValues);
    }

    // get all balances of all tokens
    function getAllTotalBalances() external view returns (address[] memory, uint256[] memory) {
        uint256 length = allTokens.length;
        address[] memory tokens = new address[](length);
        uint256[] memory balanceValues = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            tokens[i] = allTokens[i];
            balanceValues[i] = totalBalances[tokens[i]];
        }
        return (tokens, balanceValues);
    }

    // get all tokens associated with a user
    function getTokensForUser(address user) external view returns (address[] memory) {
        return walletTokens[user];
    }

    // get all users associated with a token
    function getUsersForToken(address token) external view returns (address[] memory) {
        return tokenWallets[token];
    }
}
