// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BalanceManager.sol";
import {ERC20} from "openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockERC20
 * @dev Minimal ERC20 implementation.
 */
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10 ** 18); // Mint initial supply to the deployer
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/**
 * @title BalanceManager Test
 * @dev Test contract for BalanceManager contract. This test suite covers an
 *      extensive amount all the core functionality of the contract, including
 *      fuzz examples of most of the unit tests.
 */
contract BalanceManagerTest is Test {
    BalanceManager _balanceManager;
    MockERC20 _mockTokenA;
    MockERC20 _mockTokenB;
    MockERC20 _mockTokenC;
    address _owner;
    address _admin1;
    address _admin2;
    address _user1;
    address _user2;

    uint256 _threeHundred = 300 * 10 ** 18;
    uint256 _fiveHundred = 500 * 10 ** 18;
    uint256 _oneThousand = 1000 * 10 ** 18;
    uint256 _hundredThousand = 100000 * 10 ** 18;

    function setUp() public {
        _owner = address(this);
        _admin1 = vm.addr(1);
        _admin2 = vm.addr(2);
        _user1 = vm.addr(3);
        _user2 = vm.addr(4);

        // Deploy the BalanceManager contract with the owner address
        _balanceManager = new BalanceManager(_owner);

        // Deploy the test tokens
        _mockTokenA = new MockERC20("Token A", "AMKT");
        _mockTokenB = new MockERC20("Token B", "BMKT");
        _mockTokenC = new MockERC20("Token C", "CMKT");

        // Mint tokens to the admins
        _mockTokenA.mint(_admin1, _hundredThousand);
        _mockTokenA.mint(_admin2, _hundredThousand);

        _mockTokenB.mint(_admin1, _hundredThousand);
        _mockTokenB.mint(_admin2, _hundredThousand);

        _mockTokenC.mint(_admin1, _hundredThousand);
        _mockTokenC.mint(_admin2, _hundredThousand);

        // Mint tokens to the users
        _mockTokenA.mint(_user1, _hundredThousand);
        _mockTokenC.mint(_user1, _hundredThousand);

        _mockTokenB.mint(_user2, _hundredThousand);

        // Set admin roles
        vm.startPrank(_owner);
        _balanceManager.addAdmin(_admin1);
        _balanceManager.addAdmin(_admin2);
        vm.stopPrank();

        // Log the token addresses and user/admin addresses
        console.log("Token A address:", address(_mockTokenA));
        console.log("Token B address:", address(_mockTokenB));
        console.log("Token C address:", address(_mockTokenC));
        console.log("Owner address:", _owner);
        console.log("Admin1 address:", _admin1);
        console.log("Admin2 address:", _admin2);
        console.log("User1 address:", _user1);
        console.log("User2 address:", _user2);
    }

    function test_addRemoveAdmin() public {
        address newAdmin = vm.addr(5);

        // Add new admin
        _balanceManager.addAdmin(newAdmin);
        assertTrue(_balanceManager.admins(newAdmin), "New admin should be added");
        console.log("Added new admin:", newAdmin);

        // Remove new admin
        _balanceManager.removeAdmin(newAdmin);
        assertFalse(_balanceManager.admins(newAdmin), "New admin should be removed");
        console.log("Removed new admin:", newAdmin);
    }

    function test_removedAdminWorks() public {
        vm.startPrank(_owner);

        // Add user1 as admin
        _balanceManager.addAdmin(_user1);
        assertTrue(_balanceManager.isAdmin(_user1), "User1 should be added as an admin");
        console.log("Owner added User1 as admin");

        // User1 sets balance for User2
        uint256 amount = 500 * 10 ** 18;
        vm.stopPrank();
        vm.startPrank(_user1);
        _balanceManager.setBalance(_user2, address(_mockTokenA), amount);
        console.log("User1 set balance for User2 to:", amount);
        assertEq(_balanceManager.getBalance(_user2, address(_mockTokenA)), amount, "User2 balance should be set");

        // Remove user1 as admin
        vm.stopPrank();
        vm.startPrank(_owner);
        _balanceManager.removeAdmin(_user1);
        assertFalse(_balanceManager.isAdmin(_user1), "User1 should be removed as admin");
        console.log("Owner removed User1 as admin");

        // User1 attempts to set balance for User2 again
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert("Caller is not an admin");
        _balanceManager.setBalance(_user2, address(_mockTokenA), amount);
        console.log("User1 attempted to set balance for User2 and failed as expected after being removed as admin");

        vm.stopPrank();
    }

    function test_userCannotCallAdmin() public {
        vm.startPrank(_user1);

        // Attempt to set balance as a regular user
        vm.expectRevert();
        _balanceManager.setBalance(_user2, address(_mockTokenA), _fiveHundred);
        console.log("User1 attempted to set balance for User2 and failed as expected");

        // Attempt to add an admin as a regular user
        vm.expectRevert();
        _balanceManager.addAdmin(_user1);
        console.log("User1 attempted to add themselves as an admin and failed as expected");

        // Attempt to remove an admin as a regular user
        vm.expectRevert();
        _balanceManager.removeAdmin(_admin1);
        console.log("User1 attempted to remove Admin1 and failed as expected");

        vm.stopPrank();
    }

    function test_setBalance() public {
        vm.startPrank(_admin1);

        console.log("Initial balance:", _balanceManager.balances(address(_user1), address(_mockTokenA)));
        _balanceManager.setBalance(_user1, address(_mockTokenA), _fiveHundred);
        console.log("Set balance:", _fiveHundred);
        assertEq(_balanceManager.balances(address(_user1), address(_mockTokenA)), _fiveHundred, "Balance should be set");
        assertEq(_balanceManager.totalBalances(address(_mockTokenA)), _fiveHundred, "Total balance should be updated");
        console.log("Expected balance:", _fiveHundred);
        console.log("Actual balance:", _balanceManager.balances(address(_user1), address(_mockTokenA)));

        vm.stopPrank();
    }

    function test_increaseBalance() public {
        vm.startPrank(_admin1);

        uint256 initialAmount = 300 * 10 ** 18;
        _balanceManager.setBalance(_user1, address(_mockTokenA), initialAmount);
        console.log("Initial balance for user1:", initialAmount);

        uint256 increaseAmount = 200 * 10 ** 18;
        _balanceManager.increaseBalance(_user1, address(_mockTokenA), increaseAmount);
        console.log("Increase user1 balance by:", increaseAmount);

        uint256 expectedBalance = initialAmount + increaseAmount;
        assertEq(
            _balanceManager.balances(address(_user1), address(_mockTokenA)),
            expectedBalance,
            "Balance should be increased"
        );
        assertEq(
            _balanceManager.totalBalances(address(_mockTokenA)), expectedBalance, "Total balance should be updated"
        );
        console.log("Expected user1 balance:", expectedBalance);
        console.log("Actual user1 balance:", _balanceManager.balances(address(_user1), address(_mockTokenA)));

        vm.stopPrank();
    }

    function test_reduceBalance() public {
        vm.startPrank(_admin1);

        uint256 initialAmount = 500 * 10 ** 18;
        _balanceManager.setBalance(_user1, address(_mockTokenA), initialAmount);
        console.log("Initial balance for user1:", initialAmount);

        uint256 reduceAmount = 200 * 10 ** 18;
        _balanceManager.reduceBalance(_user1, address(_mockTokenA), reduceAmount);
        console.log("Reduce user1 balance by:", reduceAmount);

        uint256 expectedBalance = initialAmount - reduceAmount;
        assertEq(
            _balanceManager.balances(address(_user1), address(_mockTokenA)),
            expectedBalance,
            "Balance should be reduced"
        );
        assertEq(
            _balanceManager.totalBalances(address(_mockTokenA)), expectedBalance, "Total balance should be updated"
        );
        console.log("Expected user1 balance:", expectedBalance);
        console.log("Actual user1 balance:", _balanceManager.balances(address(_user1), address(_mockTokenA)));

        vm.stopPrank();
    }

    function test_fuzzSetBalance(uint256 amount) public {
        vm.assume(amount <= _hundredThousand);
        vm.startPrank(_admin1);

        console.log("Setting balance for user1 to", amount);
        _balanceManager.setBalance(_user1, address(_mockTokenA), amount);

        uint256 balance = _balanceManager.getBalance(_user1, address(_mockTokenA));
        console.log("Balance for user1 after setting:", balance);

        assertEq(balance, amount, "Balance should match the set amount");
        vm.stopPrank();
    }

    function test_fuzzIncreaseBalance(uint256 amount) public {
        vm.assume(amount <= _hundredThousand);
        vm.startPrank(_admin1);

        console.log("Increasing balance for user1 by", amount);
        _balanceManager.increaseBalance(_user1, address(_mockTokenA), amount);

        uint256 balance = _balanceManager.getBalance(_user1, address(_mockTokenA));
        console.log("Balance for user1 after increase:", balance);

        assertEq(balance, amount, "Balance should match the increased amount");
        vm.stopPrank();
    }

    function test_fuzzReduceBalance(uint256 initialAmount, uint256 reduceAmount) public {
        vm.assume(initialAmount <= _hundredThousand);
        vm.assume(reduceAmount <= initialAmount);

        vm.startPrank(_admin1);

        console.log("Setting initial balance for user1 to", initialAmount);
        _balanceManager.setBalance(_user1, address(_mockTokenA), initialAmount);

        console.log("Reducing balance for user1 by", reduceAmount);
        _balanceManager.reduceBalance(_user1, address(_mockTokenA), reduceAmount);

        uint256 balance = _balanceManager.getBalance(_user1, address(_mockTokenA));
        console.log("Balance for user1 after reduction:", balance);

        assertEq(balance, initialAmount - reduceAmount, "Balance should match the reduced amount");
        vm.stopPrank();
    }

    function test_claimBalance() public {
        vm.startPrank(_admin1);

        uint256 amount = 500 * 10 ** 18;
        _balanceManager.setBalance(_user1, address(_mockTokenA), amount);

        vm.stopPrank();

        // Fund the contract with tokens
        vm.startPrank(_user1);
        _mockTokenA.approve(address(_balanceManager), amount);
        _balanceManager.fund(address(_mockTokenA), amount);
        console.log("Funded contract with tokens:", amount);
        vm.stopPrank();

        uint256 initialBalance = _mockTokenA.balanceOf(_user1);
        console.log("Initial User1 Token A balance:", initialBalance);

        vm.startPrank(_user1);
        _balanceManager.claim(address(_mockTokenA));
        uint256 claimedBalance = _mockTokenA.balanceOf(_user1);
        console.log("User1 claimed Token A balance:", claimedBalance - initialBalance);

        assertEq(_balanceManager.balances(address(_user1), address(_mockTokenA)), 0, "Balance should be claimed");
        assertEq(claimedBalance, initialBalance + amount, "User1 should receive the claimed tokens");
        console.log("User1 final Token A balance:", claimedBalance);

        vm.stopPrank();
    }

    function test_claimAllBalances() public {
        vm.startPrank(_admin1);

        _balanceManager.setBalance(_user1, address(_mockTokenA), _fiveHundred); // set token A balance to 500
        _balanceManager.setBalance(_user1, address(_mockTokenC), _threeHundred); // set token C balance to 300
        console.log("Token A balance for user1:", _fiveHundred);
        console.log("Token C balance for user1:", _threeHundred);

        vm.stopPrank();

        // Fund the contract with tokens
        vm.startPrank(_user1);
        _mockTokenA.approve(address(_balanceManager), _oneThousand); // approve for more than balance
        _mockTokenC.approve(address(_balanceManager), _oneThousand);
        _balanceManager.fund(address(_mockTokenA), _oneThousand); // fund for more than balance
        _balanceManager.fund(address(_mockTokenC), _oneThousand);
        console.log("Funded contract with Token A:", _oneThousand);
        console.log("Funded contract with Token C:", _oneThousand);
        vm.stopPrank();

        // Check initial balances
        uint256 initialTokenABalance = _mockTokenA.balanceOf(_user1);
        uint256 initialTokenCBalance = _mockTokenC.balanceOf(_user1);
        console.log("Initial User1 Token A balance:", initialTokenABalance);
        console.log("Initial User1 Token C balance:", initialTokenCBalance);

        vm.startPrank(_user1);
        _balanceManager.claimAll();
        assertEq(
            _balanceManager.balances(address(_user1), address(_mockTokenA)), 0, "Balance for Token A should be claimed"
        );
        assertEq(
            _balanceManager.balances(address(_user1), address(_mockTokenC)), 0, "Balance for Token C should be claimed"
        );

        uint256 finalTokenABalance = _mockTokenA.balanceOf(_user1);
        uint256 finalTokenCBalance = _mockTokenC.balanceOf(_user1);
        console.log("Final User1 Token A balance:", finalTokenABalance);
        console.log("Final User1 Token C balance:", finalTokenCBalance);

        assertEq(finalTokenABalance, initialTokenABalance + _fiveHundred, "User1 should receive the claimed Token A");
        assertEq(finalTokenCBalance, initialTokenCBalance + _threeHundred, "User1 should receive the claimed Token C");
        console.log("User1 claimed all balances");

        vm.stopPrank();
    }

    function test_withdrawExcessTokens() public {
        // Set up initial balances
        vm.startPrank(_admin1);

        uint256 userBalance = 500 * 10 ** 18;
        uint256 fundAmount = 500 * 10 ** 18;
        uint256 excessAmount = 500 * 10 ** 18;
        uint256 additionalAmount = 500 * 10 ** 18;
        uint256 totalAmount = fundAmount + additionalAmount;

        _balanceManager.setBalance(_user1, address(_mockTokenA), userBalance);
        console.log("Set Token A balance for user1:", userBalance);

        vm.stopPrank();

        // User1 funds the contract with Token A
        vm.startPrank(_user1);
        _mockTokenA.approve(address(_balanceManager), totalAmount);
        _balanceManager.fund(address(_mockTokenA), fundAmount);
        console.log("User1 funded contract with Token A:", fundAmount);
        vm.stopPrank();

        // Admin2 deposits additional funds to the contract
        vm.startPrank(_admin2);
        _mockTokenA.approve(address(_balanceManager), additionalAmount);
        _balanceManager.fund(address(_mockTokenA), additionalAmount);
        console.log("Admin2 funded contract with additional Token A:", additionalAmount);
        vm.stopPrank();

        // Check initial balances before withdrawal
        uint256 initialAdmin1Balance = _mockTokenA.balanceOf(_admin1);
        uint256 initialContractBalance = _mockTokenA.balanceOf(address(_balanceManager));
        console.log("Initial Admin1 Token A balance:", initialAdmin1Balance);
        console.log("Initial contract Token A balance:", initialContractBalance);

        // Admin1 withdraws excess tokens
        vm.startPrank(_admin1);
        _balanceManager.withdrawExcessTokens(address(_mockTokenA), excessAmount, _admin1);
        console.log("Admin1 withdrew excess tokens:", excessAmount);
        vm.stopPrank();

        // Check final balances after withdrawal
        uint256 finalAdmin1Balance = _mockTokenA.balanceOf(_admin1);
        uint256 finalContractBalance = _mockTokenA.balanceOf(address(_balanceManager));
        uint256 finalUserBalance = _balanceManager.balances(address(_user1), address(_mockTokenA));
        console.log("Final Admin1 Token A balance:", finalAdmin1Balance);
        console.log("Final contract Token A balance:", finalContractBalance);
        console.log("Final user1 Token A balance:", finalUserBalance);

        // Assert admin only withdrew extra tokens
        assertEq(finalAdmin1Balance, initialAdmin1Balance + excessAmount, "Admin1 should receive the excess tokens");

        // Assert user balance remains unchanged
        assertEq(finalUserBalance, userBalance, "User1 balance should remain unchanged");

        // Assert Token A in contract is still enough to cover user balance
        assertEq(finalContractBalance, userBalance, "Contract should still have enough Token A to cover user balance");
    }

    function test_withdrawExcessTokensThenClaim() public {
        // Set up initial balances
        vm.startPrank(_admin1);

        uint256 userBalance = 500 * 10 ** 18;
        uint256 fundAmount = 500 * 10 ** 18;
        uint256 excessAmount = 500 * 10 ** 18;
        uint256 additionalAmount = 500 * 10 ** 18;
        uint256 totalAmount = fundAmount + additionalAmount;

        _balanceManager.setBalance(_user1, address(_mockTokenA), userBalance);
        console.log("Set Token A balance for user1:", userBalance);

        vm.stopPrank();

        // User1 funds the contract with Token A
        vm.startPrank(_user1);
        _mockTokenA.approve(address(_balanceManager), totalAmount);
        _balanceManager.fund(address(_mockTokenA), fundAmount);
        console.log("User1 funded contract with Token A:", fundAmount);
        vm.stopPrank();

        // Admin2 deposits additional funds to the contract
        vm.startPrank(_admin2);
        _mockTokenA.approve(address(_balanceManager), additionalAmount);
        _balanceManager.fund(address(_mockTokenA), additionalAmount);
        console.log("Admin2 funded contract with additional Token A:", additionalAmount);
        vm.stopPrank();

        // Check initial balances before withdrawal
        uint256 initialAdmin1Balance = _mockTokenA.balanceOf(_admin1);
        uint256 initialContractBalance = _mockTokenA.balanceOf(address(_balanceManager));
        uint256 initialUser1Balance = _mockTokenA.balanceOf(_user1);
        console.log("Initial Admin1 Token A balance:", initialAdmin1Balance);
        console.log("Initial contract Token A balance:", initialContractBalance);
        console.log("Initial User1 Token A balance:", initialUser1Balance);

        // Admin1 withdraws excess tokens
        vm.startPrank(_admin1);
        _balanceManager.withdrawExcessTokens(address(_mockTokenA), excessAmount, _admin1);
        console.log("Admin1 withdrew excess tokens:", excessAmount);
        vm.stopPrank();

        // Check balances after withdrawal
        uint256 finalAdmin1Balance = _mockTokenA.balanceOf(_admin1);
        uint256 finalContractBalanceAfterWithdrawal = _mockTokenA.balanceOf(address(_balanceManager));
        console.log("Final Admin1 Token A balance after withdrawal:", finalAdmin1Balance);
        console.log("Final contract Token A balance after withdrawal:", finalContractBalanceAfterWithdrawal);

        // User1 claims their balance
        vm.startPrank(_user1);
        _balanceManager.claim(address(_mockTokenA));
        uint256 finalUser1Balance = _mockTokenA.balanceOf(_user1);
        console.log("User1 claimed Token A balance:", userBalance);
        vm.stopPrank();

        // Final balances
        uint256 finalContractBalance = _mockTokenA.balanceOf(address(_balanceManager));
        console.log("Final contract Token A balance:", finalContractBalance);
        console.log("Final User1 Token A balance:", finalUser1Balance);

        // Assert admin only withdrew extra tokens
        assertEq(finalAdmin1Balance, initialAdmin1Balance + excessAmount, "Admin1 should receive the excess tokens");

        // Assert user balance was claimed correctly
        assertEq(finalUser1Balance, initialUser1Balance + userBalance, "User1 should receive the claimed tokens");

        // Assert Token A in contract is now zero after user's claim
        assertEq(finalContractBalance, 0, "Contract should have zero Token A after user's claim");
    }

    function test_adminFundsUserClaims() public {
        // Log initial user balance
        uint256 initialUser1Balance = _mockTokenA.balanceOf(_user1);
        console.log("Initial User1 Token A balance:", initialUser1Balance);

        // Admin1 funds the contract
        vm.startPrank(_admin1);
        uint256 fundAmount = 1000 * 10 ** 18;
        _mockTokenA.approve(address(_balanceManager), fundAmount);
        _balanceManager.fund(address(_mockTokenA), fundAmount);
        console.log("Admin1 funded contract with Token A:", fundAmount);

        // Admin1 sets balance for User1
        uint256 userBalance = 500 * 10 ** 18;
        _balanceManager.setBalance(_user1, address(_mockTokenA), userBalance);
        console.log("Admin1 set Token A balance for User1:", userBalance);

        vm.stopPrank();

        // User1 claims their balance
        vm.startPrank(_user1);
        _balanceManager.claim(address(_mockTokenA));
        uint256 claimedBalance = _mockTokenA.balanceOf(_user1) - initialUser1Balance;
        console.log("User1 claimed Token A balance:", claimedBalance);

        vm.stopPrank();

        // Final user balance
        uint256 finalUser1Balance = _mockTokenA.balanceOf(_user1);
        console.log("Final User1 Token A balance:", finalUser1Balance);

        // Assertions
        assertEq(claimedBalance, userBalance, "User1 should receive the claimed balance");
        assertTrue(finalUser1Balance > initialUser1Balance, "User1 should have more tokens than initially");
    }

    // attempt to set balance for contract address
    function test_cannotAddContractBalance() public {
        vm.startPrank(_admin1);

        address contractAddress = address(_balanceManager);
        vm.expectRevert(BalanceManager.ContractCannotBeTheUser.selector);
        _balanceManager.setBalance(contractAddress, address(_mockTokenA), _fiveHundred);

        vm.stopPrank();
    }

    // assert contract cannot receive ETH
    function test_cannotReceiveEth() public {
        vm.expectRevert(bytes("Contract should not accept ETH"));
        (bool success,) = address(_balanceManager).call{value: 1 ether}("");
        console.log("ETH transfer success status:", success);
        assertFalse(success, "Contract should not be able to accept ETH");
    }
}
