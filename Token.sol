// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// An ERC20 implementation
contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) public balanceOf;

    address public owner;

    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 1000000;

    // Enable an owner to give allowance to multiple addresses
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18;

        owner = msg.sender;
    }

    // Only owner can mint tokens for given addresses
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "action not permitted");
        require(
            totalSupply + amount <= MAX_SUPPLY,
            "cannot mint more than max supply"
        );

        totalSupply += amount;
        balanceOf[to] += amount;
    }

    // Use to DRY up code - internal to prevent anyone from spending tokens
    function helperTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        // Check that balance is high enough for the transfer
        // Prevent burning
        require(balanceOf[from] >= amount, "not enough tokens");
        require(to != address(0), "burn not permitted");

        // Update balances, bookkeepping
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        return true;
    }

    // Direct transfer from sender account
    function transfer(address to, uint256 amount) public returns (bool) {
        return helperTransfer(msg.sender, to, amount);
    }

    // Approving another account to spend an amount from sender account
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;

        return true;
    }

    // Transferring someone elses tokens
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        // Check if spender has enough allowance to spend someone elses tokens, deduct if approved
        if (msg.sender != from) {
            require(
                allowance[from][msg.sender] >= amount,
                "not enough allowance"
            );
            allowance[from][msg.sender] -= amount; // very important to prevent unlimited spending power
        }

        return helperTransfer(from, to, amount);
    }
}
