// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTest} from "test/BaseTest.t.sol";
import {FixedPrice} from "src/minters/FixedPrice.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {FxGenArt721} from "src/FxGenArt721.sol";

contract FirstComeFirstServeTest is BaseTest {
    FixedPrice internal sale;
    FxGenArt721 internal mockToken;
    uint256 internal price = 1 ether;
    uint256 internal quantity = 1;
    uint256 internal supply = 100;
    uint64 internal startTime = uint64(block.timestamp);
    uint64 internal endTime = type(uint64).max;

    function setUp() public override {
        super.setUp();
        mockToken = new FxGenArt721(address(fxContractRegistry), address(fxRoleRegistry));
        vm.deal(address(this), 100 ether);
        sale = new FixedPrice();
        // mockToken.initialize();
    }
}

contract BuyTokens is FirstComeFirstServeTest {
    function test_buyTokens() public {
        vm.warp(block.timestamp + 1);
        sale.buyTokens(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {}

    function test_RevertsIf_InsufficientWETHBalance() public {}

    function test_RevertsIf_NotStarted() public {}

    function test_RevertsIf_Ended() public {}

    function test_RevertsIf_WETHNotApproved() public {}

    function test_RevertsIf_TokenAddress0() public {}

    function test_RevertsIf_ToAddress0() public {
        // this should revert via underlying token checks.
        // including incase we change token implementations
    }

    function test_RevertsIf_Purchase0() public {}
}

contract SetMintDetails is FirstComeFirstServeTest {
    function test_setMintDetails() public {
        uint256 price = 10;
        uint128 allocation = 100;
        uint64 start = uint64(block.timestamp + 10);
        uint64 end = type(uint64).max;
        sale.setMintDetails(ReserveInfo(start, end, allocation), abi.encode(price));
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        (uint64 startTime, uint64 endTime, uint160 allocation_) = sale.reserves(address(this), 0);
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        assertEq(startTime, start, "startTime incorrectly set");
        assertEq(endTime, end, "endTime incorrectly set");
        assertEq(allocation_, allocation, "allocation incorrectly set");
    }

    function test_RevertsIf_StartTimeGtEndTime() public {}

    function test_RevertsIf_Allocation0() public {}

    function test_RevertsIf_Price0() public {}

    /// might want to store fee receiver here to save external call
    function test_RevertsIf_FeeReceiverAddress0() public {}
}

contract Withdraw is FirstComeFirstServeTest {
    function test_withdraw() public {}
}
