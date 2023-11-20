// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/factories/FxTicketFactory/FxTicketFactoryTest.t.sol";

contract CreateTicket is FxTicketFactoryTest {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_CreateTicket() public {
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
        assertEq(fxTicketFactory.tickets(ticketId), fxMintTicketProxy);
        assertEq(FxMintTicket721(fxMintTicketProxy).owner(), creator);
    }

    function test_RevertsWhen_InvalidGracePeriod() public {
        vm.expectRevert(INVALID_GRACE_PERIOD_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY - 1),
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            address(0),
            fxGenArtProxy,
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            address(0),
            address(ticketRedeemer),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidRedeemer() public {
        vm.expectRevert(INVALID_REDEEMER_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(0),
            address(ipfsRenderer),
            uint48(ONE_DAY),
            mintInfo
        );
    }

    function test_RevertsWhen_InvalidRenderer() public {
        vm.expectRevert(INVALID_RENDERER_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(
            creator,
            fxGenArtProxy,
            address(ticketRedeemer),
            address(0),
            uint48(ONE_DAY),
            mintInfo
        );
    }
}
