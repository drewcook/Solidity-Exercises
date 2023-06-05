// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

contract FizzBuzz {
    function fizzBuzz(uint256 n) public pure returns (string memory) {
        if (n % 3 == 0 && n % 5 == 0) {
            // if n is divisible be 3 and 5, return "fizz buzz"
            return "fizz buzz";
        } else if (n % 3 == 0) {
            // if n is divisible by 3, return "fizz"
            return "fizz";
        } else if (n % 5 == 0) {
            // if n is divisible by 5, return "buzz"
            return "buzz";
        } else {
            // otherwise, return an empty string
            return "";
        }
    }
}
