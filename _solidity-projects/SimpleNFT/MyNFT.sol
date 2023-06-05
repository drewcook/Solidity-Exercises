// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    using Strings for uint256;

    // Define token supply
    uint256 public tokenSupply; // 0
    uint256 public constant MAX_SUPPLY = 5; // more gas efficient than non-constant
    uint256 public constant PRICE = 1 ether;

    address immutable deployer;

    constructor() ERC721("MyNFT", "DCO") {
        deployer = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://...../";
    }

    function mint() external payable {
        // 0, 1, 2, 3, 4
        require(tokenSupply < MAX_SUPPLY, "collection sold out");
        require(msg.value == PRICE, "wrong price");

        _mint(msg.sender, tokenSupply);
        tokenSupply++;
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // withdrawing from owner who deployed
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Anyone can withdraw to the deployer
    // function withdraw() external {
    //     payable(deployer).transfer(address(this).balance);
    // }

    // override inheritied ownership fns
    function renounceOwnership() public override {
        require(false, "cannot renounce");
    }

    function transferOwnership(address newOwner) public override {
        require(false, "cannot transfer");
    }
}
