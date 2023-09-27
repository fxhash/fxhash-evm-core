// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/DutchAuction/DutchAuctionTest.t.sol";

contract Buy is DutchAuctionTest {
    uint256 internal quantity = 1;

    function test_buy() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        quantity = RESERVE_MINTER_ALLOCATION + 1;
        vm.expectRevert(TOO_MANY_ERROR);
        dutchAuction.buy{value: (price * (RESERVE_MINTER_ALLOCATION + 1))}(
            fxGenArtProxy, quantity, alice
        );
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_InvalidPayment() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        dutchAuction.buy{value: price - 1}(fxGenArtProxy, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_NotStarted() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_Ended() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_TokenAddress0() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        vm.expectRevert(INVALID_TOKEN_ERROR);
        dutchAuction.buy{value: price}(address(0), 1, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_ToAddress0() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, address(0));
    }

    function test_RevertsIf_Purchase0() public {
        (, uint256 price) = dutchAuction.getPrice(fxGenArtProxy);
        quantity = 0;
        vm.expectRevert(AMOUNT_ZERO_ERROR);
        dutchAuction.buy{value: price}(fxGenArtProxy, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }
}
