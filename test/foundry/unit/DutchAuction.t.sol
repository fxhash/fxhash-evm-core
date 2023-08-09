// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {console} from "forge-std/Test.sol";
import {Base} from "test/foundry/Base.t.sol";
import {IWETH} from "contracts/interfaces/IWETH.sol";
import {DutchAuctionMint} from "contracts/minters/DutchAuctionMint.sol";
import {Minted} from "contracts/minters/base/Minted.sol";
import {MockGenerativeToken, Reserve} from "test/mocks/MockGenerativeToken.sol";
import {IMinter} from "contracts/interfaces/IMinter.sol";

contract DutchAuctionTest is Base {
    DutchAuctionMint public sale;
    MockGenerativeToken public mockToken;
    uint256 public price = 1 ether;
    uint256 public quantity = 1;
    uint256 public supply = 100;
    uint40 startTime = uint40(block.timestamp);
    uint40 endTime = type(uint40).max;

    function setUp() public override {
        super.setUp();
        mockToken = new MockGenerativeToken();
        vm.deal(address(this), 100 ether);
        sale = new DutchAuctionMint();
        IWETH(payable(weth9)).deposit{value: 1 ether}();
        IWETH(payable(weth9)).approve(address(sale), type(uint256).max);
    }
}
