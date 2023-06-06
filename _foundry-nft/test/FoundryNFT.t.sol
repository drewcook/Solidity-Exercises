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
}
