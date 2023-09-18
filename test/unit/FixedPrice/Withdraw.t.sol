// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "test/unit/FixedPrice/FixedPrice.t.sol";

contract Withdraw is FixedPriceTest {
    uint256 internal quantity = 1;
    uint256 internal mintId = 0;

    function test_withdraw() public {
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        uint256 beforeBalance = creator.balance;
        sale.withdraw(fxGenArtProxy);
        uint256 afterBalance = creator.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        sale.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        vm.expectRevert(abi.encodeWithSelector(IFixedPrice.InsufficientFunds.selector));
        sale.withdraw(address(0));
    }
}
