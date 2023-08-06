// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {Test, console} from "forge-std/Test.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    HelperConfig public helperConfig;

    address immutable USER = makeAddr("user");
    uint256 constant USER_BALANCE = 100 ether;
    uint256 constant WITH_VALUE = 1;
    uint256 constant WITHOUT_VALUE = 0;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helperConfig) = deployer.run();
        vm.deal(USER, USER_BALANCE);
    }

    function testUserFundInteraction() public {
        FundFundMe fundFundMe = new FundFundMe();
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();

        fundFundMe.funding(address(fundMe));

        assertEq(fundMe.getFundersNumber(), 1);

        withdrawFundMe.WithdrawFundFundMe(address(fundMe));
        assertEq(fundMe.getBalance(), 0);
    }
}
