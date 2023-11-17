// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract SetMintDetails is TicketRedeemerTest {
    function test_SetMintDetails() public {
        ticketRedeemer.setMintDetails(reserveInfo, mintDetails);
    }

    function test_RevertsWhen_AlreadySet() public {
        ticketRedeemer.setMintDetails(reserveInfo, mintDetails);
        vm.expectRevert(ALREAD_SET_ERROR);
        ticketRedeemer.setMintDetails(reserveInfo, mintDetails);
    }

    function test_RevertsWhen_InvalidEncoding() public {
        vm.expectRevert();
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket), 1));
    }
}
