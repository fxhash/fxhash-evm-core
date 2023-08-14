// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {console} from "forge-std/Test.sol";
import {Base} from "test/foundry/Base.t.sol";
import {IWETH} from "src/interfaces/IWETH.sol";
import {FixedPriceAllowlistMint} from "src/minters/FixedPriceAllowlistMint.sol";
import {Minted} from "src/minters/base/Minted.sol";
import {MockGenerativeToken, Reserve} from "test/mocks/MockGenerativeToken.sol";
import {IMinter} from "src/interfaces/IMinter.sol";

contract FirstComeFirstServeTest is Base {
    FixedPriceAllowlistMint public sale;
    MockGenerativeToken public mockToken;
    bytes32 public merkleRoot;
    bytes32[] public proof;
    address public vault;
    uint256 public index;
    uint256 public price = 1 ether;
    uint256 public quantity = 1;
    uint256 public supply = 100;
    uint40 startTime = uint40(block.timestamp);
    uint40 endTime = type(uint40).max;

    function setUp() public override {
        super.setUp();
        mockToken = new MockGenerativeToken();
        vm.deal(address(this), 100 ether);
        sale = new FixedPriceAllowlistMint();
        IWETH(payable(weth9)).deposit{value: 1 ether}();
        IWETH(payable(weth9)).approve(address(sale), type(uint256).max);
    }
}

contract BuyTokens is FirstComeFirstServeTest {
    function testbuyTokens() public {
        mockToken.registerMinter(
            address(sale),
            Reserve(uint160(supply), startTime, endTime),
            abi.encode(price, merkleRoot)
        );
        vm.warp(block.timestamp + 1);
        sale.buyTokens(address(mockToken), vault, index, proof, address(this));
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
        uint160 allocation = 100;
        uint40 start = uint40(block.timestamp + 10);
        uint40 end = type(uint40).max;
        sale.setMintDetails(Reserve(allocation, start, end), abi.encode(price));
        assertEq(sale.prices(address(this)), price, "price incorrectly set");
        (uint160 allocation_, uint40 startTime, uint40 endTime) = sale.reserves(address(this));
        assertEq(sale.prices(address(this)), price, "price incorrectly set");
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
