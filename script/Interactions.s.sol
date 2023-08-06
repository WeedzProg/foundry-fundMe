// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;

import {Script, console} from "forge-std/Script.sol";
import {DeployFundMe} from "./DeployFundMe.s.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1; // just a value to make sure we are sending enough!

    function funding(address mostRecentContract) public {
        vm.startBroadcast();

        FundMe(payable(mostRecentContract)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log("Funded FundMe contract %s with %s", mostRecentContract, SEND_VALUE);
    }

    function run() external {
        address mostRecentContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        funding(mostRecentContract);
    }
}

contract WithdrawFundMe is Script {
    function WithdrawFundFundMe(address mostRecentContract) public {
        vm.startBroadcast();

        FundMe(payable(mostRecentContract)).withdraw();
        vm.stopBroadcast();

        console.log("Withdraw FundMe contract %s", mostRecentContract);
    }

    function run() external {
        address mostRecentContract = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        WithdrawFundFundMe(mostRecentContract);
    }
}
