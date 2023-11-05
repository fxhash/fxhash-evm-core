// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";
import "test/mocks/MockTicket.sol";
import "test/mocks/MockFxGenArt721Params.sol";

contract TicketRedeemerTest is BaseTest {
    MockTicket internal ticket;
    MockFxGenArt721Params internal token;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        ticketRedeemer = new TicketRedeemer();
        ticket = new MockTicket();
        token = new MockFxGenArt721Params();
    }
}
