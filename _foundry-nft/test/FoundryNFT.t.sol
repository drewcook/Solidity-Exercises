// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FoundryNFT.sol";

// Goals:
// - aim for 100% line and branch coverage
// - fully define the expected state transitions
// - use error messages in your asserts
// see: https://www.rareskills.io/post/foundry-testing-solidity

contract FoundryNFTTest is Test {
    FoundryNFT public nft;

    address public deployer = address(this);
    address public buyer = address(0x01);
    address public buyer2 = address(0x02);

    receive() external payable {
        // have this here if testing withdrawing from a contract so the funds can send here
    }

    // If testing transferring NFTs to this contract/account, prevent ERC721.safeTransferFrom and ERC115.transferFrom from reverting due to not having this signature as a transfer hook callback
    // function onERC721Received() external {}

    function setUp() public {
        nft = new FoundryNFT();
    }

    function testName() public {
        assertEq(nft.name(), "FoundryNFT", "Name should be correct");
    }

    function testSymbol() public {
        assertEq(nft.symbol(), "FNFT", "Symbol should be correct");
    }

    function testMint() public {
        assertEq(address(nft).balance, 0, "contract balance should be zero");
        assertEq(nft.balanceOf(buyer), 0, "buyer balance should be zero");
        assertEq(nft.totalSupply(), 0, "total supply should be zero");

        vm.deal(buyer, 1 ether);
        vm.prank(buyer);
        nft.mint{value: 0.01 ether}();

        // // Check minting address becomes owner of the token
        assertEq(nft.ownerOf(1), buyer, "buyer should be owner of token");
        // // Check that their balance increases by 1
        assertEq(
            nft.balanceOf(buyer),
            1,
            "buyer's balance should increase by one"
        );
        // // Check that contract balance went up by price of NFT
        assertEq(nft.totalSupply(), 1, "total supply should be zero");
        assertEq(
            address(nft).balance,
            0.01 ether,
            "contract balance should increase by NFT price"
        );
    }

    function testMintPrice() public {
        // Should only allow minting with correct price
        vm.prank(buyer);
        vm.expectRevert();
        nft.mint{value: 1 ether}();

        vm.prank(buyer2);
        vm.expectRevert();
        nft.mint{value: 0.001 ether}();
    }

    function testWithdraw() public {
        // Check that only owner can withdraw
        vm.prank(buyer);
        vm.expectRevert();
        nft.withdraw();

        // Check that after withdraw, owner's balance increases by that amount and contract balance is zero
        uint256 amount = address(nft).balance;
        uint256 balanceBefore = address(deployer).balance;
        vm.prank(deployer);
        nft.withdraw();
        assertEq(address(nft).balance, 0, "contract balance should be zero");
        uint256 balanceAfter = address(deployer).balance;
        assertEq(
            balanceAfter,
            balanceBefore + amount,
            "owner balance should increase by that of the contract balance"
        );
    }
}
