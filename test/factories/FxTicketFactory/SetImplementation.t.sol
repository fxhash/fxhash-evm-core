// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract SetImplementation is FxTicketFactoryTest {
    function test_SetImplementation() public {
        vm.prank(fxTicketFactory.owner());
        fxTicketFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxTicketFactory.implementation(), address(fxMintTicket721));
    }

    function test_RevertsWhen_NotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        fxTicketFactory.setImplementation(address(fxMintTicket721));
    }
}
