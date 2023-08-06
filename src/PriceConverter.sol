// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title PriceConverter
/// @dev A library that can convert ETH to its USD price equivalent and get the actual price of ETH

// import Chainlink for price feed
import {AggregatorV3Interface} from
    "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /// @dev Gets the current price of ETH from a Chainlink price feed
    /// @return The current price of ETH in wei
    function getPriceEth(AggregatorV3Interface _priceFeedAddress) internal view returns (uint256) {
        // Specify the address of the ETH/USD price feed contract
        // Get the latest round data from the price feed
        (, int256 price,,,) = _priceFeedAddress.latestRoundData();

        // Convert the price to wei
        return uint256(price * 1e10);
    }

    /// @dev Converts ETH into its USD equivalent
    /// @param ethAmount The amount of ETH to convert
    /// @return The equivalent amount in USD
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface _priceFeedAddress) internal view returns (uint256) {
        uint256 ethPrice = getPriceEth(_priceFeedAddress);
        uint256 ethToUsd = (ethPrice * ethAmount) / 1e18;

        return ethToUsd;
    }
}
