// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract CreateTicket is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_createTicket() public {
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            uint48(ONE_DAY),
            BASE_URI,
            mintInfo
        );
        assertEq(FxMintTicket721(fxMintTicketProxy).owner(), creator);
        assertEq(fxTicketFactory.tickets(ticketId), fxMintTicketProxy);
    }

    function test_RevertsWhen_InvalidGracePeriod() public {
        vm.expectRevert(INVALID_GRACE_PERIOD_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            uint48(ONE_DAY - 1),
            BASE_URI,
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            address(0),
            fxGenArtProxy,
            address(ticketRedeemer),
            uint48(ONE_DAY),
            BASE_URI,
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            address(0),
            address(ticketRedeemer),
            uint48(ONE_DAY),
            BASE_URI,
            mintInfo
        );
    }
}
