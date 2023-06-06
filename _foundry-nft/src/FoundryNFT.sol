// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@oz/token/ERC721/ERC721.sol";

contract FoundryNFT is ERC721 {
    uint256 public totalSupply = 0;
    uint256 public constant PRICE = 0.01 ether;

    constructor() ERC721("FoundryNFT", "FNFT") {}

    function mint() external payable {
        require(msg.value == PRICE, "wrong price");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }
}
