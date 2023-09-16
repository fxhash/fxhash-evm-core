// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract BuyTokens is FixedPriceTest {
    function test_buy() public {
        vm.warp(block.timestamp);
        sale.buy{value: price}(address(mockToken), 0, 1, alice);
        assertEq(mockToken.balanceOf(alice), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.TooMany.selector));
        sale.buy{value: (price * (supply + 1))}(address(mockToken), 0, supply + 1, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }

    function test_RevertsIf_InsufficientPayent() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidPayment.selector));
        sale.buy{value: price - 1}(address(mockToken), 0, 1, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }

    function test_RevertsIf_NotStarted() public {
        vm.warp(block.timestamp - 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.NotStarted.selector));
        sale.buy{value: price}(address(mockToken), 0, 1, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }

    function test_RevertsIf_Ended() public {
        vm.warp(uint256(endTime) + 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.Ended.selector));
        sale.buy{value: price}(address(mockToken), 0, 1, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }

    function test_RevertsIf_TokenAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidToken.selector));
        sale.buy{value: price}(address(0), 0, 1, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }

    function test_RevertsIf_ToAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.AddressZero.selector));
        sale.buy{value: price}(address(mockToken), 0, 1, address(0));
    }

    function test_RevertsIf_Purchase0() public {
        vm.expectRevert();
        sale.buy{value: price}(address(mockToken), 0, 0, alice);
        assertEq(mockToken.balanceOf(alice), 0);
    }
}
