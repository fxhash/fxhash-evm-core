// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {console} from "forge-std/Test.sol";
import {Base} from "test/foundry/Base.t.sol";
import {FixedPriceMint} from "src/minters/FixedPriceMint.sol";
import {IWETH} from "src/interfaces/IWETH.sol";
import {Minted} from "src/minters/base/Minted.sol";
import {MockGenerativeToken, Reserve} from "test/mocks/MockGenerativeToken.sol";
import {IMinter} from "src/interfaces/IMinter.sol";

contract OpenEditionTest is Base {
    FixedPriceMint public sale;
    MockGenerativeToken public mockToken;
    uint256 public price = 1 ether;
    uint256 public quantity = 1;
    uint256 public supply = type(uint160).max;
    uint40 duration = 100;
    uint40 startTime = uint40(block.timestamp);
    uint40 endTime = uint40(block.timestamp + duration);

    function setUp() public override {
        super.setUp();
        mockToken = new MockGenerativeToken();
        vm.deal(address(this), 100 ether);
        sale = new FixedPriceMint();
        IWETH(payable(weth9)).deposit{value: 1 ether}();
        IWETH(payable(weth9)).approve(address(sale), type(uint256).max);
    }
}

contract BuyTokens is OpenEditionTest {
    function testbuyTokens() public {
        mockToken.registerMinter(
            address(sale), Reserve(uint160(supply), startTime, endTime), abi.encode(price)
        );
        vm.warp(block.timestamp + 1);
        sale.buyTokens(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 1);
    }

    function test_RevertsIf_BuyMoreThanUint160Max() public {}

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

contract SetMintDetails is OpenEditionTest {
    function test_setMintDetails() public {
        uint256 price = 10;
        uint160 allocation = type(uint160).max;
        uint40 start = uint40(block.timestamp + 10);
        uint40 end = uint40(block.timestamp + 100);
        sale.setMintDetails(Reserve(allocation, start, end), abi.encode(price));
        assertEq(sale.prices(address(this), 0), price, "price incorrectly set");
        (uint160 allocation_, uint40 startTime, uint40 endTime) = sale.reserves(address(this), 0);
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
