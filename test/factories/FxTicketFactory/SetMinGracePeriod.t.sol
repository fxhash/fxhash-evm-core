// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetMintGracePeriod is FxTicketFactoryTest {
    function test_SetMintGracePeriod() public {
        vm.prank(fxTicketFactory.owner());
        fxTicketFactory.setMinGracePeriod(0);
        assertEq(fxTicketFactory.minGracePeriod(), 0);
    }

    function test_RevertsWhen_NotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        fxTicketFactory.setMinGracePeriod(0);
    }
}
