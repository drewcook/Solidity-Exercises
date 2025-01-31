// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract CrossContract {
    /**
     * The function below is to call the price function of PriceOracle1 and PriceOracle2 contracts below and return the lower of the two prices
     */

    function getLowerPrice(
        address _priceOracle1,
        address _priceOracle2
    ) external returns (uint256) {
        // get first oracle price
        (bool ok1, bytes memory data1) = _priceOracle1.call(
            abi.encodeWithSignature("price()")
        );
        require(ok1, "call failed to oracle 1 - price()");

        // get second oracle price
        uint256 price1 = abi.decode(data1, (uint256));
        (bool ok2, bytes memory data2) = _priceOracle2.call(
            abi.encodeWithSignature("price()")
        );
        uint256 price2 = abi.decode(data2, (uint256));
        require(ok2, "call failed to oracle 1 - price()");

        // get the lowest
        return price1 <= price2 ? price1 : price2;
    }
}

contract PriceOracle1 {
    uint256 private _price;

    function setPrice(uint256 newPrice) public {
        _price = newPrice;
    }

    function price() external view returns (uint256) {
        return _price;
    }
}

contract PriceOracle2 {
    uint256 private _price;

    function setPrice(uint256 newPrice) public {
        _price = newPrice;
    }

    function price() external view returns (uint256) {
        return _price;
    }
}

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
        (bool ok1, bytes memory dataBalanceTraded) = _tokenToTrade.call(
            abi.encodeWithSignature("balanceOf", msg.sender)
        );
        (bool ok2, bytes memory dataBalanceReceived) = _tokenToReceive.call(
            abi.encodeWithSignature("balanceOf", msg.sender)
        );
        uint256 newBalanceTradedIn = abi.decode(dataBalanceTraded, (uint256));
        uint256 newBalanceReceived = abi.decode(dataBalanceReceived, (uint256));
        require(
            newBalanceTradedIn == existingBalanceTradedIn + _amount,
            "balances not updated correctly"
        );
        require(
            newBalanceReceived == existingBalanceReceived + _amount,
            "balances not updated correctly"
        );

        return true;
    }
}
