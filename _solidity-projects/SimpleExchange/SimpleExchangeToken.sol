// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// A simple ERC20 implementation
contract ExchangeToken {
    string public name;
    string public symbol;
    uint256 public decimals;

    uint256 public immutable max_supply;
    uint256 public total_supply;

    address public owner;

    mapping(address => uint256) public balanceOf;

    // Enable an owner to give allowance to multiple addresses
    // owner => has allowed 0x0 => of n amount
    mapping(address => mapping(address => uint256)) public allowances;

    // ERC-20 Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(string memory _name, string memory _symbol, address _owner) {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        // 1 million max
        max_supply = 1000000;
        // default to deployer
        owner = _owner != address(0) ? _owner : msg.sender;
    }

    // Minting a given amount and add to the sender's balance
    function mint(address _to, uint256 _amount) public {
        // TODO: add require that only owner can mint this
        require(total_supply + _amount <= max_supply, "max supply reached");
        // increase total supply
        total_supply += _amount;
        // bookkeeping
        balanceOf[_to] += _amount;

        emit Transfer(address(0), _to, _amount);
    }

    // Approving for a spender to spend up to a given amount from the sender's balance
    function approve(address _approvee, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_approvee] = _amount;
        emit Approval(msg.sender, _approvee, _amount);
        return true;
    }

    // Transfer helper function
    function _transferToken(
        address _from,
        address _to,
        uint256 _amount
    ) internal returns (bool) {
        require(balanceOf[_from] >= _amount, "insufficient funds");
        // prevent burning
        require(_to != address(0), "cannot send to zero address");

        // bookkeeping
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);

        return true;
    }

    function transfer(address _to, uint256 _amount) public returns (bool) {
        return _transferToken(msg.sender, _to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        // Check that the from has allowed sender to transfer this amount
        // Support calling this from the owner's account
        // Deduct allowance to prevent unlimited spending
        if (msg.sender != _from) {
            require(
                allowances[_from][msg.sender] >= _amount,
                "not allowed to spend this amount"
            );
            allowances[_from][msg.sender] -= _amount;
        }

        return _transferToken(_from, _to, _amount);
    }
}
