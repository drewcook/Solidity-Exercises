// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

// A simple exchange for trading/swapping between two custom tokens
// Exchanges a 1:1 amount between tokens
contract Exchange {
    address public owner;

    // Total combined balance of all tokens for a given accounts
    mapping(address => uint256) public totalBalanceOf;

    // Balances of each token for a given account
    mapping(address => mapping(address => uint256)) public balanceOf;

    function mintToken(address _token, uint256 _amount) public returns (bool) {
        (bool ok, bytes memory data) = _token.call(
            abi.encodeWithSignature(
                "mint(address,uint256)",
                msg.sender,
                _amount
            )
        );
        require(ok, "minting token failed");

        return true;
    }

    // Trade one token for the another for a given amount
    function trade(
        address _tokenToTrade,
        address _tokenToReceive,
        uint256 _amount
    ) public returns (bool) {
        // Approve amounts
        (bool t1_ok, bytes memory approveData1) = _tokenToTrade.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                _tokenToReceive,
                _amount
            )
        );
        (bool t2_ok, bytes memory approveData2) = _tokenToReceive.call(
            abi.encodeWithSignature(
                "approve(address,uint256)",
                _tokenToTrade,
                _amount
            )
        );

        // Transfer amounts
        // TODO: this is buggy
        (bool t1_ok2, bytes memory transferData1) = _tokenToTrade.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                _tokenToReceive,
                _tokenToTrade,
                _amount
            )
        );
        (bool t2_ok2, bytes memory transferData2) = _tokenToReceive.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                _tokenToTrade,
                _tokenToReceive,
                _amount
            )
        );

        require(
            t1_ok && t1_ok2 && t2_ok && t2_ok2,
            "one or more transactions failed"
        );

        // Balance bookkeeping
        uint256 existingBalanceTradedIn = balanceOf[msg.sender][_tokenToTrade];
        uint256 existingBalanceReceived = balanceOf[msg.sender][
            _tokenToReceive
        ];
        existingBalanceTradedIn -= _amount;
        existingBalanceReceived += _amount;

        // Ensure correct calculations
        // (bool ok1, bytes memory dataBalanceTraded) = _tokenToTrade.call(abi.encodeWithSignature("balanceOf", msg.sender));
        // (bool ok2, bytes memory dataBalanceReceived) = _tokenToReceive.call(abi.encodeWithSignature("balanceOf", msg.sender));
        // uint256 newBalanceTradedIn = abi.decode(dataBalanceTraded, (uint256));
        // uint256 newBalanceReceived = abi.decode(dataBalanceReceived, (uint256));
        // require(newBalanceTradedIn == existingBalanceTradedIn + _amount, "balances not updated correctly");
        // require(newBalanceReceived == existingBalanceReceived + _amount, "balances not updated correctly");

        return true;
    }
}
