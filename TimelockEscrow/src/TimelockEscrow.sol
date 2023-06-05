// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract TimelockEscrow {
    address public seller;

    mapping(address => uint256) private buyOrders;
    mapping(address => uint256) private lastOrderPlaced;

    /**
     * The goal of this exercise is to create a Time lock escrow.
     * A buyer deposits ether into a contract, and the seller cannot withdraw it until 3 days passes. Before that, the buyer can take it back
     * Assume the owner is the seller
     */

    constructor() {
        seller = msg.sender;
    }

    // creates a buy order between msg.sender and seller
    /**
     * escrows msg.value for 3 days which buyer can withdraw at anytime before 3 days but afterwhich only seller can withdraw
     * should revert if an active escrow still exist or last escrow hasn't been withdrawn
     */
    function createBuyOrder() external payable {
        // your code here
        buyOrders[msg.sender] = msg.value;
        lastOrderPlaced[msg.sender] = block.timestamp;
    }

    /**
     * allows seller to withdraw after 3 days of the escrow with @param buyer has passed
     */
    function sellerWithdraw(address buyer) external {
        // your code here
        require(
            block.timestamp > lastOrderPlaced[buyer] + 3 days,
            "can only withdraw after 3 days from user's deposit"
        );
        require(buyOrders[buyer] > 0, "buyer does not have any orders");
        uint256 saleAmt = buyOrders[buyer];
        buyOrders[buyer] = 0;
        lastOrderPlaced[buyer] = 0;
        (bool ok, ) = seller.call{value: saleAmt}("");
        require(ok, "transfer failed");
    }

    /**
     * allow a buyer to withdraw at anytime before the end of the escrow (3 days)
     */
    function buyerWithdraw() external {
        // your code here
        require(msg.sender != seller, "seller cannot call this");
        require(buyOrders[msg.sender] > 0, "no buy orders found to withdraw");
        require(
            lastOrderPlaced[msg.sender] + 3 days > block.timestamp,
            "can only withdraw within 3 days"
        );
        uint256 withdrawAmt = buyOrders[msg.sender];
        buyOrders[msg.sender] = 0;
        lastOrderPlaced[msg.sender] = 0;
        (bool ok, ) = msg.sender.call{value: withdrawAmt}("");
        require(ok, "transfer failed");
    }

    // returns the escrowed amount of @param buyer
    function buyerDeposit(address buyer) external view returns (uint256) {
        // your code here
        return buyOrders[buyer];
    }
}
