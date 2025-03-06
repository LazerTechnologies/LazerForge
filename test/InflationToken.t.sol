// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/InflationToken.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

// Mock ERC20 Token for testing recovery
contract MockERC20 is ERC20 {
    constructor() ERC20("OtherToken", "OTK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract InflationTokenTest is Test {
    InflationToken _token;
    address _owner = address(this); // set the owner to the test contract
    address _user = address(2);
    address _user2 = address(3);
    MockERC20 _otherToken;

    function setUp() public {
        _token = new InflationToken();
        _otherToken = new MockERC20();
        console.log("Setup completed. Owner address:", _owner, "User address:", _user);
    }

    function testInitialSupply() public {
        uint256 initialSupply = 1_000_000_000 * 10 ** _token.decimals();
        console.log("Testing Initial Supply");
        console.log("Expected initial supply:", initialSupply);
        console.log("Actual initial supply:", _token.totalSupply());
        assertEq(_token.totalSupply(), initialSupply);
        console.log("Expected owner balance:", initialSupply);
        console.log("Actual owner balance:", _token.balanceOf(_owner));
        assertEq(_token.balanceOf(_owner), initialSupply);
    }

    function testInflation() public {
        uint256 initialSupply = 1_000_000_000 * 10 ** _token.decimals();

        // Try minting after 1 day - should fail
        vm.warp(block.timestamp + 1 days);
        console.log("Fast forwarded 1 day");
        vm.expectRevert(InflationToken.MintingDateNotReached.selector);
        _token.mint(_owner);

        // Try minting after 1 year - should succeed
        vm.warp(block.timestamp + 365 days);
        console.log("Fast forwarded to 1 year");
        _token.mint(_owner);
        assertEq(_token.totalSupply(), initialSupply + _token.MINT_CAP());

        // Try minting after 1 more day - should fail
        vm.warp(block.timestamp + 1 days);
        console.log("Fast forwarded 1 more day");
        vm.expectRevert(InflationToken.MintingDateNotReached.selector);
        _token.mint(_owner);

        // Try minting after another year - should succeed
        vm.warp(block.timestamp + 365 days);
        console.log("Fast forwarded to 2 years");
        _token.mint(_owner);
        assertEq(_token.totalSupply(), initialSupply + (_token.MINT_CAP() * 2));
    }

    function testMintToContractAddressBlocked() public {
        vm.warp(block.timestamp + 365 days);

        console.log("Attempting to mint to contract address, expecting revert");
        vm.expectRevert(InflationToken.CannotMintToBlockedAddress.selector);
        _token.mint(address(_token));
    }

    function testRecoverTokens() public {
        vm.warp(block.timestamp + 365 days);
        _token.mint(_owner);
        _token.transfer(address(_token), _token.MINT_CAP());

        uint256 contractBalanceBefore = _token.balanceOf(address(_token));
        console.log("Contract balance before recovery:", contractBalanceBefore);
        uint256 ownerBalanceBefore = _token.balanceOf(_owner);
        console.log("Owner balance before recovery:", ownerBalanceBefore);

        _token.recoverTokens(address(_token), _token.MINT_CAP(), _owner);

        uint256 contractBalanceAfter = _token.balanceOf(address(_token));
        uint256 ownerBalanceAfter = _token.balanceOf(_owner);
        console.log("Contract balance after recovery:", contractBalanceAfter);
        console.log("Owner balance after recovery:", ownerBalanceAfter);

        assertEq(contractBalanceAfter, contractBalanceBefore - _token.MINT_CAP());
        assertEq(ownerBalanceAfter, ownerBalanceBefore + _token.MINT_CAP());
    }

    function testTotalSupplyAfterInflation() public {
        console.log("Testing Total Supply After Inflation for 5 years");
        console.log("Inflation is a constant 5% of the initial supply each year");
        uint256 initialSupply = 1_000_000_000 * 10 ** _token.decimals();

        for (uint256 year = 1; year <= 5; year++) {
            vm.warp(block.timestamp + 365 days);
            _token.mint(_owner);
            uint256 expectedSupply = initialSupply + (_token.MINT_CAP() * year);
            console.log("Year", year, "- Minted amount:", _token.MINT_CAP());
            console.log("Year", year, "- Expected Total Supply:", expectedSupply);
            console.log("Year", year, "- Actual Total Supply:", _token.totalSupply());
            assertEq(_token.totalSupply(), expectedSupply);
        }
    }

    function testTransferOwnership() public {
        console.log("Testing Ownership Transfer");
        _token.transferOwnership(_user);
        console.log("Ownership transferred to user");
    }

    function testTokenTransfers() public {
        console.log("Testing Token Transfers");
        uint256 ownerBalanceBefore = _token.balanceOf(_owner);
        console.log("Owner balance before transfer:", ownerBalanceBefore);
        _token.transfer(_user, 100);
        console.log("Transferred 100 tokens to user");
        assertEq(_token.balanceOf(_user), 100);
        console.log("User balance after transfer:", _token.balanceOf(_user));
        assertEq(_token.balanceOf(_owner), ownerBalanceBefore - 100);
        console.log("Owner balance after transfer:", _token.balanceOf(_owner));
    }

    function testRecoverOtherToken() public {
        console.log("Testing Recover Other Token");
        _otherToken.mint(address(_token), 100);
        console.log("Transferred 100 OtherToken to contract");
        _token.recoverTokens(address(_otherToken), 100, _owner);
        console.log("Recovered 100 OtherToken from contract to owner");
        assertEq(_otherToken.balanceOf(_owner), 100);
    }

    function testBurnTokens() public {
        console.log("Testing Token Burning");
        uint256 initialSupply = _token.totalSupply();
        console.log("Initial total supply:", initialSupply);
        _token.burn(100);
        console.log("Burned 100 tokens");
        assertEq(_token.totalSupply(), initialSupply - 100);
        console.log("Total supply after burning:", _token.totalSupply());
    }

    function testCannotReceiveEth() public {
        vm.expectRevert(bytes("Contract should not accept ETH"));
        (bool success,) = address(_token).call{value: 1 ether}("");
        console.log("ETH transfer success status:", success);
        assertFalse(success, "Contract should not be able to accept ETH");
    }

    function testAccess() public {
        console.log("Testing access to token attributes and ownership");
        assertEq(_token.name(), "InflationToken", "Token name should be InflationToken");
        assertEq(_token.symbol(), "INFLA", "Token symbol should be INFLA");
        assertEq(_token.decimals(), 18, "Token decimals should be 18");
        assertEq(_token.totalSupply(), 1_000_000_000 * 10 ** _token.decimals(), "Total supply should be 1 billion");
        assertEq(_token.owner(), _owner, "Owner should be the initial owner");
    }
}
