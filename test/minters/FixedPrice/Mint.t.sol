// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

import {Ownable} from "solady/src/auth/Ownable.sol";

contract Mint is FixedPriceTest {
    function test_Mint() public {
        vm.prank(FRAME_CONTROLLER);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
        (, , uint128 remainingAllocation) = fixedPrice.reserves(fxGenArtProxy, mintId);

        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
        assertEq(remainingAllocation, MINTER_ALLOCATION - quantity);
        assertEq(fixedPrice.totalMinted(fId, fxGenArtProxy), quantity);
    }

    function test_RevertWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fixedPrice.mint(address(0), mintId, fId, alice);
    }

    function test_RevertWhen_InvalidReserve() public {
        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId + 1, fId, alice);
    }

    function test_RevertsWhen_Unauthorized() public {
        vm.expectRevert(Ownable.Unauthorized.selector);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
    }

    function test_RevertsWhen_MaxAmountExceeded() public {
        vm.startPrank(FRAME_CONTROLLER);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
        vm.expectRevert(MAX_AMOUNT_EXCEEDED_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
        vm.stopPrank();
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.prank(FRAME_CONTROLLER);
        vm.expectRevert(NOT_STARTED_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.prank(FRAME_CONTROLLER);
        vm.expectRevert(ENDED_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
    }

    function test_RevertsWhen_TooMany() public {
        vm.startPrank(FRAME_CONTROLLER);
        (platformFee, , ) = feeManager.calculateFees(fxGenArtProxy, price, MINTER_ALLOCATION);
        price = (price * MINTER_ALLOCATION) + platformFee;
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, MINTER_ALLOCATION, alice);
        vm.expectRevert(TOO_MANY_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId, fId, alice);
        vm.stopPrank();
    }

    function test_RevertsWhen_AddressZero() public {
        vm.prank(FRAME_CONTROLLER);
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPrice.mint(fxGenArtProxy, mintId, quantity, address(0));
    }
}
