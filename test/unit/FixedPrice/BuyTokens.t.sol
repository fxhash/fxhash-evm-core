// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract BuyTokens is FixedPriceTest {
    function test_buyTokens() public {
        vm.warp(block.timestamp);
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 1);
    }

    function test_RevertsIf_BuyMoreThanAllocation() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.TooMany.selector));
        sale.buyTokens{value: (price * (supply + 1))}(
            address(mockToken), 0, supply + 1, address(this)
        );
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_InsufficientPayent() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidPayment.selector));
        sale.buyTokens{value: price - 1}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_NotStarted() public {
        vm.warp(block.timestamp - 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.NotStarted.selector));
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_Ended() public {
        vm.warp(uint256(endTime) + 1);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.Ended.selector));
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_TokenAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidToken.selector));
        sale.buyTokens{value: price}(address(0), 0, 1, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }

    function test_RevertsIf_ToAddress0() public {
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.AddressZero.selector));
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(0));
    }

    function test_RevertsIf_Purchase0() public {
        vm.expectRevert();
        sale.buyTokens{value: price}(address(mockToken), 0, 0, address(this));
        assertEq(mockToken.balanceOf(address(this)), 0);
    }
}
