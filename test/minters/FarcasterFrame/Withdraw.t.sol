// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/minters/FarcasterFrame/FarcasterFrameTest.t.sol";

contract Withdraw is FarcasterFrameTest {
    function test_Withdraw() public {
        farcasterFrame.buy{value: price}(fxGenArtProxy, reserveId, quantity, alice);
        uint256 beforeBalance = primaryReceiver.balance;
        farcasterFrame.withdraw(fxGenArtProxy);
        uint256 afterBalance = primaryReceiver.balance;
        assertEq(beforeBalance + price, afterBalance);
    }

    function test_RevertsWhen_InsufficientFunds() public {
        vm.prank(CONTROLLER);
        farcasterFrame.mint(fxGenArtProxy, reserveId, fId, alice);
        vm.expectRevert(INSUFFICIENT_FUNDS_ERROR);
        farcasterFrame.withdraw(fxGenArtProxy);
    }
}
