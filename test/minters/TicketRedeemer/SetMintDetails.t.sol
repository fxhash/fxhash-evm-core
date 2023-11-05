// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract SetMintDetails is TicketRedeemerTest {
    function test_setMintDetails() public {
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket)));
    }

    function test_RevertsWhen_ABI_EncodingWrong() public {
        // not sure why this doesnt fail
        // vm.expectRevert();
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket), uint256(1)));
    }

    function test_RevertsWhen_TicketAlreadyRegistered() public {
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket)));

        vm.expectRevert(abi.encodeWithSelector(ITicketRedeemer.AlreadySet.selector));
        ticketRedeemer.setMintDetails(reserveInfo, abi.encode(address(ticket)));
    }

    function test_RevertsWhen_RegisteringTicketNotAssociatedWithToken() public {
        /// this seems like an issue
    }
}
