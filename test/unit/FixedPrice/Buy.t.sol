// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract BuyTokens is FixedPriceTest {
    uint256 internal mintId = 0;
    uint256 internal quantity = 1;

    function test_buy() public {
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {
        quantity = RESERVE_MINTER_ALLOCATION + 1;
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.TooMany.selector));
        sale.buy{value: (price * (RESERVE_MINTER_ALLOCATION + 1))}(
            fxGenArtProxy, mintId, quantity, alice
        );
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_InsufficientPayent() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidPayment.selector));
        sale.buy{value: price - 1}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_NotStarted() public {
        vm.warp(RESERVE_START_TIME - 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.NotStarted.selector));
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_Ended() public {
        vm.warp(uint256(RESERVE_END_TIME) + 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.Ended.selector));
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_TokenAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidToken.selector));
        sale.buy{value: price}(address(0), 0, 1, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }

    function test_RevertsIf_ToAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.AddressZero.selector));
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, address(0));
    }

    function test_RevertsIf_Purchase0() public {
        quantity = 0;
        vm.expectRevert();
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        assertEq(FxGenArt721(fxGenArtProxy).balanceOf(alice), 0);
    }
}
