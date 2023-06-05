// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract DistributeV2 {
    /*
        This exercise assumes you know how to sending Ether.
        1. This contract has some ether in it, distribute it equally among the
           array of addresses that is passed as argument.
        2. Write your code in the `distributeEther` function.
        3. Consider scenarios where one of the recipients rejects the ether transfer,
           have a work around for that whereby other recipients still get their transfer
    */

    constructor() payable {}

    function distributeEther(address[] memory addresses) public {
        // your code here
        uint256 count = addresses.length;
        uint256 amount = address(this).balance / count;
        uint256 rejections = 0;
        address[] memory acceptions = addresses;
        // Distribute evently, keeping track of who accepts and rejects
        for (uint256 i = 0; i < count; i++) {
            // some may reject the transfers, keep track of that
            (bool ok, ) = addresses[i].call{value: amount}("");
            if (!ok) {
                rejections++;
            } else {
                // pop and swap so we filter out rejecting addresses
                address last = acceptions[acceptions.length - 1];
                delete acceptions[i];
                acceptions[i] = last;
            }
        }
        // If any rejected the first distribution, transfer out remaining amount to those that didn't
        if (rejections > 0) {
            uint256 remainingAmt = address(this).balance / acceptions.length;
            for (uint256 i = 0; i < acceptions.length; i++) {
                // distribute remaining amount to those who accepted
                acceptions[i].call{value: remainingAmt}("");
            }
        }
    }
}
