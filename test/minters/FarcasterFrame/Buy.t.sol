// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

contract Buy is FarcasterFrameTest {
    function test_Buy() public {
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        (, , uint128 remainingAllocation) = farcasterFrame.reserves(fxGenArtProxy, reserveId);

        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
        assertEq(remainingAllocation, MINTER_ALLOCATION - quantity);
        assertEq(farcasterFrame.getSaleProceeds(fxGenArtProxy), price);
    }

    function test_RevertWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        farcasterFrame.buy{value: price}(address(0), reserveId, quantity, alice);
    }

    function test_RevertWhen_InvalidReserve() public {
        vm.expectRevert(INVALID_RESERVE_ERROR);
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId + 1, quantity, alice);
    }

    function test_RevertsWhen_InvalidPayent() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        farcasterFrame.buy{value: price - 1}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_TooMany() public {
        quantity = MINTER_ALLOCATION + 1;
        vm.expectRevert(TOO_MANY_ERROR);
        farcasterFrame.buy{value: (price * quantity)}(fxGenArtProxy, reserveId, quantity, alice);
    }

    function test_RevertsWhen_AddressZero() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId, quantity, address(0));
    }
}
