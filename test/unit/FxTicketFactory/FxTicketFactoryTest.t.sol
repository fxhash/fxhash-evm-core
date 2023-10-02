// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxGenArt721Test} from "test/unit/FxGenArt721/FxGenArt721Test.t.sol";
import {IFxTicketFactory} from "src/interfaces/IFxTicketFactory.sol";

contract FxTicketFactoryTest is FxGenArt721Test {
    // Custom Errors
    bytes4 INVALID_GRACE_PERIOD_ERROR = IFxTicketFactory.InvalidGracePeriod.selector;
    bytes4 INVALID_OWNER_ERROR = IFxTicketFactory.InvalidOwner.selector;
    bytes4 INVALID_TOKEN_ERROR = IFxTicketFactory.InvalidToken.selector;

    function setUp() public virtual override {
        super.setUp();
        ticketId = 1;
    }

    function test_createTicket() public {
        fxMintTicketProxy =
            fxTicketFactory.createTicket(creator, fxGenArtProxy, uint48(ONE_DAY), BASE_URI);
        assertEq(FxMintTicket721(fxMintTicketProxy).owner(), creator);
        assertEq(fxTicketFactory.tickets(ticketId), fxMintTicketProxy);
    }

    function test_RevertsWhen_InvalidGracePeriod() public {
        vm.expectRevert(INVALID_GRACE_PERIOD_ERROR);
        fxMintTicketProxy =
            fxTicketFactory.createTicket(creator, fxGenArtProxy, uint48(ONE_DAY - 1), BASE_URI);
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxMintTicketProxy =
            fxTicketFactory.createTicket(address(0), fxGenArtProxy, uint48(ONE_DAY), BASE_URI);
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fxMintTicketProxy =
            fxTicketFactory.createTicket(creator, address(0), uint48(ONE_DAY), BASE_URI);
    }

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxIssuerFactory.implementation(), address(fxMintTicket721));
    }
}
