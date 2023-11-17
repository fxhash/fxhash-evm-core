// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {MockTicket} from "test/mocks/MockTicket.sol";

contract TicketRedeemerTest is BaseTest {
    // State
    MockTicket internal ticket;
    bytes internal mintDetails;

    // Errors
    bytes4 internal ALREAD_SET_ERROR = ITicketRedeemer.AlreadySet.selector;
    bytes4 internal INVALID_TOKEN_ERROR = ITicketRedeemer.InvalidToken.selector;
    bytes4 internal NOT_AUTHORIZED_ERROR = ITicketRedeemer.NotAuthorized.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        tokenId = 1;
        ticket = new MockTicket();
        ticketRedeemer = new TicketRedeemer();
        minter = address(new MockMinter());
        mintDetails = abi.encode(address(ticket));
    }
}
