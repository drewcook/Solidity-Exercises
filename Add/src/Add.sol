// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13; // overflow protection added in after 0.8.0

contract Add {
    uint256 sum = 10 + 5;
    uint256 x = 1;
    uint256 y = 2;
    uint256 xy = x + y;
    uint256 exp = 2 ** 5;
    int256 remainder = 10 % 3;
    // floats don't exist with uints
    uint256 interest = 200 * 0.1; // fails, instead convert to * 1/10
    uint256 interest2 = 200 / 10; // 10%
    uint256 interest3 = (200 * 75) / 1000; // 7.5%
    // division is tricky with ints
    uint256 cityPopulation = 1000;
    uint256 nationPopulation = 10000;
    uint256 fractionOfPopulation = cityPopulation / nationPopulation; // will be zero!

    function add(uint256 a, uint256 b) public pure returns (uint256) {
        // your code here
        // can allow overflows/underflows with an unchecked block
        unchecked {
            uint256 z = a - b; // z == 2**256-1
        }
        return a + b;
    }
}
