// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// This token can be traded in for RareTokens. The exchange rate is 5 SkilTokens for every 1 RareToken (5:1)
contract SkilToken {
    address public owner;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public max_supply;
    uint256 public total_supply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        max_supply = 5000;
    }

    function mint(address to, uint256 amount) public returns (bool) {
        require(
            total_supply + amount <= max_supply,
            "cannot mint more than max supply"
        );
        total_supply += amount;
        balanceOf[to] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
        return true;
    }

    function _transferToken(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        require(
            balanceOf[from] >= amount,
            "not enough funds to cover this transfer"
        );
        require(to != address(0), "cannot send to zero address");

        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transferToken(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        if (msg.sender != from) {
            require(
                allowances[from][msg.sender] >= amount,
                "spender not allowed to transfer this amount of funds"
            );
            allowances[from][msg.sender] -= amount; // to prevent unlimited spending
        }

        return _transferToken(from, to, amount);
    }
}

// Can trade in 5 SkilCoins for 1 RareCoin
// Cannot swap them back, it is a one-way trade
// TODO: Allow for capturing in what it deposited in and allow the reverse trade to happen
contract RareCoin {
    address public owner;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public max_supply;
    uint256 public total_supply;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public tokenDepositBalance;

    constructor(string memory _name, string memory _symbol) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = 18;
        max_supply = 1000;
    }

    function trade(address token, uint256 amount) external returns (bool) {
        require(amount % 5 != 0, "must send in increments of 5");

        uint256 tokensToMint = amount / 5;
        require(
            total_supply + tokensToMint <= max_supply,
            "cannot mint more than max supply"
        );

        // transfer in the 5 tokens from SkilCoin
        (bool ok, ) = token.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                msg.sender,
                address(this),
                amount
            )
        );
        require(ok, "call to transferFrom failed");

        total_supply += tokensToMint;
        balanceOf[msg.sender] += tokensToMint;
        tokenDepositBalance[token] += amount;

        return true;
    }
}
