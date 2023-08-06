// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title FundMe
/// @dev A contract for receiving funds from users, allowing the owner to withdraw funds, and setting a minimum value in USD to fund.
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__InsufficientAmount();

contract FundMe {
    using PriceConverter for uint256;

    /// @dev Minimum USD equivalent value to fund
    uint256 private constant MINIMUM_USD = 5e18;

    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    address[] private s_funders;

    mapping(address => uint256) private amountFundedByAddress;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /// @dev Function to allow users to send money to this contract, requiring a minimum value in USD
    function fund() public payable {
        if (msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD) {
            revert FundMe__InsufficientAmount();
        }
        //require(msg.value.getConversionRate() >= MINIMUM_USD, "Amount is not enough for funding.");

        s_funders.push(msg.sender);
        amountFundedByAddress[msg.sender] += msg.value;
    }

    /// @dev Function to withdraw funds from this contract, only the owner can withdraw
    function withdraw() public payable onlyOwner returns (bool) {
        bool sent;
        uint256 contractAmount = address(this).balance;

        // Reset mapping
        for (uint256 i = 0; i < s_funders.length; i++) {
            amountFundedByAddress[s_funders[i]] = 0;
        }

        // Reset funders array
        s_funders = new address[](0);

        (bool success, ) = i_owner.call{value: contractAmount}("");
        unchecked {
            sent = success;
        }
        return sent;
    }

    // Gas Efficient withdraw function
    function cheaperWithdraw() public payable onlyOwner returns (bool) {
        bool sent;
        uint256 funders_length = s_funders.length;
        uint256 contractAmount = address(this).balance;

        // Reset mapping
        for (uint256 i = 0; i < funders_length; i++) {
            amountFundedByAddress[s_funders[i]] = 0;
        }

        // Reset funders array
        s_funders = new address[](0);

        (bool success, ) = i_owner.call{value: contractAmount}("");
        unchecked {
            sent = success;
        }
        return sent;
    }

    /// @dev Function to get the balance of this contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Function to get the minimum required USD amount for funding
    function getMinimum() public pure returns (uint256) {
        return MINIMUM_USD;
    }

    /// @dev Function to get the number of funders, to know the max index of the array
    function getFundersNumber() public view returns (uint256) {
        return s_funders.length;
    }

    /// @dev Function to get the funder at a specific index
    function getFunderAddressAtIndex(uint256 _index) public view returns (address) {
        return s_funders[_index];
    }

    /// @dev Function to get the historical total amount funded by a specific address
    function getAmountFundedByAddress(address _funder) public view returns (uint256) {
        return amountFundedByAddress[_funder];
    }

    /// @dev Function to get the latest price from the price feed
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    uint256 private receiveResult;

    receive() external payable {
        fund();
        receiveResult++;
    }

    function getReceiveResult() public view returns (uint256) {
        return receiveResult;
    }

    uint256 private fallbackResult;

    fallback() external payable {
        fund();
        fallbackResult++;
    }

    function getFallbackResult() public view returns (uint256) {
        return fallbackResult;
    }
}
