// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetwork;

    uint8 constant DECIMALS = 8;

    int256 constant MOCK_PRICE = 2000e8;

    uint256 chainId = block.chainid;
    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (chainId == 11155111) {
            activeNetwork = sepoliaNetwork();
        } else if (chainId == 80001) {
            activeNetwork = mumbaiNetwork();
        } else if (chainId == 1) {
            activeNetwork = ethMainnetFork();
        } else {
            activeNetwork = anvilNetwork();
        }
    }

    function anvilNetwork() public returns (NetworkConfig memory anvilEthUsd) {
        if (activeNetwork.priceFeed != address(0)) {
            return activeNetwork;
        }
        // if local deploy mocks, takes decimals and price
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, MOCK_PRICE);
        vm.stopBroadcast();

        //attribute mock address
        NetworkConfig memory anvilEthUsd = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilEthUsd;
    }

    function sepoliaNetwork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaEthUSD = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });

        return sepoliaEthUSD;
    }

    function mumbaiNetwork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mumbaiEthUSD = NetworkConfig({
            priceFeed: 0x0715A7794a1dc8e42615F059dD6e406A6594651A
        });

        return mumbaiEthUSD;
    }

    function ethMainnetFork() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetEthUsd = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetEthUsd;
    }
}
