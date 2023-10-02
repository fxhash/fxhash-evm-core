// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Withdraw is DutchAuctionTest {
    uint256 internal quantity = 1;

    function test_withdraw() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId,quantity, alice);
        uint256 beforeBalance = creator.balance;

        vm.warp(RESERVE_END_TIME+ 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        uint256 afterBalance = creator.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.withdraw(address(0), reserveId);
    }
}
