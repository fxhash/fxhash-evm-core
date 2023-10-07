// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Withdraw is DutchAuctionTest {
    function test_withdraw() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        uint256 beforeBalance = primaryReceiver.balance;

        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_NotOver() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME - 1);
        vm.expectRevert(NOT_ENDED_ERROR);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
    }

    function test_RevertsIf_NoFunds() public {
        uint256 price = dutchAuction.getPrice(fxGenArtProxy, reserveId);
        dutchAuction.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        vm.warp(RESERVE_END_TIME + 1);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);

        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        dutchAuction.withdraw(fxGenArtProxy, reserveId);
    }

    function test_RevertsIf_Token0() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.withdraw(address(0), reserveId);
    }
}
