// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FixedPriceParams/FixedPriceParamsTest.t.sol";

contract Buy is FixedPriceParamsTest {
        function test_Buy() public {
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_RevertWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fixedPriceParams.buy{value: price}(address(0), mintId, alice, fxParams);
    }

    function test_RevertsWhen_InvalidReserve() public {
        vm.expectRevert(INVALID_RESERVE_ERROR);
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId + 1, alice, fxParams);
    }

    function test_RevertsWhen_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(NOT_STARTED_ERROR);
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
    }

    function test_RevertsWhen_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(ENDED_ERROR);
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, alice, fxParams);
    }

    function test_RevertsWhen_AddressZero() public {
        vm.expectRevert(ADDRESS_ZERO_ERROR);
        fixedPriceParams.buy{value: price}(fxGenArtProxy, mintId, address(0), fxParams);
    }

    function test_RevertsWhen_InvalidPayment() public {
        vm.expectRevert(INVALID_PAYMENT_ERROR);
        fixedPriceParams.buy{value: price - 1}(fxGenArtProxy, mintId, alice, fxParams);
    }
}
