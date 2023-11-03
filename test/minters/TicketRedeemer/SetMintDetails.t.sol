// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/minters/TicketRedeemer/TicketRedeemerTest.t.sol";

contract SetMintDetails is TicketRedeemerTest {
    function test_setMintDetails() public {
        ticketRedeemer.setMintDetails(
            ReserveInfo(RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION),
            abi.encode(address(420))
        );
    }
}
