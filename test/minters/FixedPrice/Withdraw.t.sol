// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/FixedPrice/FixedPriceTest.t.sol";

contract Withdraw is FixedPriceTest {
    function setUp() public override {
        mintDetails = abi.encode(PRICE);
        super.setUp();
    }

    function test_withdraw() public {
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        uint256 beforeBalance = primaryReceiver.balance;
        fixedPrice.withdraw(fxGenArtProxy);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsIf_Token0() public {
        fixedPrice.buy{value: price}(fxGenArtProxy, mintId, quantity, alice);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        fixedPrice.withdraw(address(0));
    }
}
