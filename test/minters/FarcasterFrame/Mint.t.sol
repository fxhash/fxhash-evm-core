// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";

contract Mint is FarcasterFrameTest {
    function test_Mint() public {
        vm.prank(ADMIN);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        (, , uint128 remainingAllocation) = farcasterFrame.reserves(fxGenArtProxy, reserveId);

        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
        assertEq(remainingAllocation, MINTER_ALLOCATION - quantity);
        assertEq(farcasterFrame.totalMinted(fId, fxGenArtProxy), quantity);
    }

    function test_RevertWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        farcasterFrame.mint(address(0), reserveId, fId, alice);
    }

    function test_RevertWhen_InvalidReserve() public {
        vm.expectRevert(INVALID_RESERVE_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId + 1, fId, alice);
    }

    function test_RevertsWhen_Unauthorized() public {
        vm.expectRevert(Ownable.Unauthorized.selector);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
    }

    function test_RevertsWhen_MaxAmountExceeded() public {
        vm.startPrank(ADMIN);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        vm.expectRevert(MAX_AMOUNT_EXCEEDED_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        vm.stopPrank();
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.prank(ADMIN);
        vm.expectRevert(NOT_STARTED_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.prank(ADMIN);
        vm.expectRevert(ENDED_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
    }

    function test_RevertsWhen_TooMany() public {
        vm.startPrank(ADMIN);
        farcasterFrame.buy{value: price * MINTER_ALLOCATION}(fxGenArtProxy, reserveId, MINTER_ALLOCATION, alice);
        vm.expectRevert(TOO_MANY_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        vm.stopPrank();
    }

    function test_RevertsWhen_AddressZero() public {
        vm.prank(ADMIN);
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        farcasterFrame.mint(fxGenArtProxy, reserveId, quantity, address(0));
    }
}
