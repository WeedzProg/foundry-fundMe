// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title FallbackExample
/// @dev A contract to demonstrate the order of function calls when sending Ether to a contract.

contract FallbackExample {
    uint256 public result;
    uint256 public result2;

    /*
    Which function is called, fallback() or receive()?

           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
    receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */

    /// @dev Function to receive Ether.
    /// @notice This function is called when the transaction data (msg.data) is empty.
    receive() external payable {
        result++;
    }

    /// @dev Fallback function is called when the transaction data (msg.data) is not empty.
    fallback() external payable {
        result2++;
    }
}
