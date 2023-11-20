// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockTicket} from "test/mocks/MockTicket.sol";
import {MockToken} from "test/mocks/MockToken.sol";

contract TicketRedeemerTest is BaseTest {
    // State
    MockTicket internal ticket;
    MockToken internal token;
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
        token = new MockToken();
        ticket = new MockTicket();
        ticketRedeemer = new TicketRedeemer();
        mintDetails = abi.encode(address(ticket));
    }
}
