// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract Buy is FixedPriceTest {
    function test_Buy() public {
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_RevertsWhen_TooMany() public {
        quantity = MINTER_ALLOCATION + 1;
        vm.expectRevert(TOO_MANY_ERROR);
        fixedPrice.buy{value: (price * (MINTER_ALLOCATION + 1))}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_InvalidPayent() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        fixedPrice.buy{value: price - 1}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }

    function test_RevertWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fixedPrice.buy{value: price}(address(0), 0, 1, alice);
    }

    function test_RevertsWhen_AddressZero() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, address(0));
    }

    function test_RevertsWhen_PurchaseZero() public {
        quantity = 0;
        vm.expectRevert();
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
    }
}
