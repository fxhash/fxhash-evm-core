// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract Withdraw is FixedPriceTest {
    receive() external payable {}

    function test_withdraw() public {
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        sale.withdraw(address(mockToken));
    }

    function test_RevertsIf_Token0() public {
        sale.buyTokens{value: price}(address(mockToken), 0, 1, address(this));
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InvalidToken.selector));
        sale.withdraw(address(0));
    }
}
