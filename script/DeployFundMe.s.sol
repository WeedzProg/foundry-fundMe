// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe, HelperConfig) {
        // code outside vm.broadcast is not runned. it is simulated
        HelperConfig helperConfig = new HelperConfig();
        address ethToUsd = helperConfig.activeNetwork();

        vm.startBroadcast();

        FundMe fundMe = new FundMe(ethToUsd);

        vm.stopBroadcast();
        return (fundMe, helperConfig);
    }
}
