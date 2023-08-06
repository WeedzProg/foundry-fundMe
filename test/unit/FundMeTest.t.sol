// SPDX-License-Identifier:MIT

pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

// import {log} from "forge-std/console2.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    HelperConfig public helperConfig;

    address immutable USER = makeAddr("user");
    uint256 constant USER_BALANCE = 100 ether;
    uint256 constant WITH_VALUE = 1;
    uint256 constant WITHOUT_VALUE = 0;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe();

        // deploy from deploy scripts

        DeployFundMe deployFundMe = new DeployFundMe();
        (fundMe, helperConfig) = deployFundMe.run();
        vm.deal(USER, USER_BALANCE);
    }

    function testAggregatorVersion() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testPriceFeedSetCorrectly() public {
        address retrievedPriceFeed = address(fundMe.getPriceFeed());
        // (address expectedPriceFeed) = helperConfig.activeNetworkConfig();
        address expectedPriceFeed = helperConfig.activeNetwork();
        assertEq(retrievedPriceFeed, expectedPriceFeed);
    }

    function testMinimumUSDValue() public {
        assertEq(fundMe.getMinimum(), 5e18);
    }

    function testOwnerIsSender() public {
        //as FundMeTest is deploying a new FundMe the owner will be actually this contract address. not msg.sender.
        //console.log(fundMe);
        //console.log(msg.sender);

        // since we did change where the deployment happens.
        // and since it is between vm.broadcast which concerns msg.sender transactions. owner is msg.sender again
        // assertEq(fundMe.i_owner(), address(this));

        console.log("Changing owner from %s to %s", msg.sender, address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    //function testOwnerIsNotContract() public {
    //vm.expectRevert();
    //assertEq(fundMe.i_owner(), address(this));
    //}

    function testNotEnoughFund() public {
        vm.expectRevert();
        fundMe.fund{value: 1e18}();
        fundMe.getBalance();
    }

    function testFundMeBalanceAfterFunding() public {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();

        assertEq(fundMe.getBalance(), WITH_VALUE);
    }

    function testNumberOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();
        assertEq(fundMe.getFundersNumber(), 1);
    }

    function testFunderIndex() public {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();

        assertEq(fundMe.getFunderAddressAtIndex(0), USER);
    }

    function testFundByFundersAddress() public {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();

        assertEq(fundMe.getAmountFundedByAddress(USER), 1);
    }

    function testRevertWithdrawNotOwner() public {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    // function testOwnerWithdraw() public {
    //     vm.startPrank(USER);
    //     fundMe.fund{value: WITH_VALUE}();
    //     assertEq(fundMe.getBalance(), 1);
    //     vm.stopPrank();

    //     vm.prank(fundMe.getOwner());
    //     fundMe.withdraw();
    //     assertEq(fundMe.getBalance(), 0);
    // }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: WITH_VALUE}();
        _;
    }

    function testOwnerWithdrawFunded() public funded {
        //Arrange
        uint256 beforeWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundedFundMeBalance = fundMe.getBalance();

        //Act
        uint256 gasBefore = gasleft(); //gas before tx

        vm.txGasPrice(GAS_PRICE); //simulate gas price for anvil, set to 1 here
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasAfter = gasleft(); // gas left after tx

        uint256 gasUsed = (gasBefore - gasAfter) * tx.gasprice;
        //console::f5b1bba9(0000000000000000000000000000000000000000000000000000000000002a5e) [staticcall]
        //cast --to-base 0x000000000000000000000000000000000000000000000000000000000002a5e dec
        //10846

        console.log(gasUsed);

        //Assert
        uint256 afterWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeAfterWithdraw = fundMe.getBalance();

        assertEq(fundMeAfterWithdraw, 0);
        assertEq(afterWithdrawOwnerBalance, beforeWithdrawOwnerBalance + fundedFundMeBalance);
        assertEq(fundMe.getFundersNumber(), 0); //array reset
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i));
            // vm.deal(funders, 100);

            //Hoax create an address with funds
            //addresses generated by a number in that case must be an uint160
            hoax(address(i), USER_BALANCE);
            fundMe.fund{value: WITH_VALUE}();
        }

        uint256 beforeWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundedFundMeBalance = fundMe.getBalance();

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 afterWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeAfterWithdraw = fundMe.getBalance();

        assertEq(fundMeAfterWithdraw, 0);
        assertEq(afterWithdrawOwnerBalance, beforeWithdrawOwnerBalance + fundedFundMeBalance);
        assertEq(fundMe.getFundersNumber(), 0); //array reset
    }

    function testWithdrawFromMultipleFunderscheaperWithdraw() public {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1;

        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i));
            // vm.deal(funders, 100);

            //Hoax create an address with funds
            //addresses generated by a number in that case must be an uint160
            hoax(address(i), USER_BALANCE);
            fundMe.fund{value: WITH_VALUE}();
        }

        uint256 beforeWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundedFundMeBalance = fundMe.getBalance();

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 afterWithdrawOwnerBalance = fundMe.getOwner().balance;
        uint256 fundMeAfterWithdraw = fundMe.getBalance();

        assertEq(fundMeAfterWithdraw, 0);
        assertEq(afterWithdrawOwnerBalance, beforeWithdrawOwnerBalance + fundedFundMeBalance);
        assertEq(fundMe.getFundersNumber(), 0); //array reset
    }

    function testSendEthToContractAddress() public {
        vm.expectRevert();
        vm.prank(USER);
        payable(address(fundMe)).transfer(1 ether);

        assertEq(fundMe.getFallbackResult(), 0);
        assertEq(fundMe.getReceiveResult(), 0);
    }
}
