// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract Withdraw is FixedPriceTest {
    function test_withdraw() public {
        sale.buy{value: price}(address(mockToken), 0, 1, alice);
        uint256 beforeBalance = address(this).balance;
        sale.withdraw(address(mockToken));
        uint256 afterBalance = address(this).balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        sale.buy{value: price}(address(mockToken), 0, 1, alice);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InsufficientFunds.selector));
        sale.withdraw(address(0));
    }
}
