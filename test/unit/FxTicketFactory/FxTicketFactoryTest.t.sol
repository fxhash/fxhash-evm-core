// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxTicketFactoryTest is BaseTest {
    // Errors
    bytes4 INVALID_GRACE_PERIOD_ERROR = IFxTicketFactory.InvalidGracePeriod.selector;
    bytes4 INVALID_OWNER_ERROR = IFxTicketFactory.InvalidOwner.selector;
    bytes4 INVALID_TOKEN_ERROR = IFxTicketFactory.InvalidToken.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockMinter(admin);
        _mockSplits(SPLITS_DEPLOYER);
        _configureSplits();
        _configureRoyalties();
        _configureProject(ENABLED, ONCHAIN, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, PRICE);
        _grantRole(admin, MINTER_ROLE, minter);
        _createSplit();
        _createProject();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CREATE TICKET
    //////////////////////////////////////////////////////////////////////////*/

    function test_createTicket() public {
        fxMintTicketProxy = fxTicketFactory.createTicket(creator, fxGenArtProxy, uint48(ONE_DAY), BASE_URI);
        assertEq(FxMintTicket721(fxMintTicketProxy).owner(), creator);
        assertEq(fxTicketFactory.tickets(ticketId), fxMintTicketProxy);
    }

    function test_RevertsWhen_InvalidGracePeriod() public {
        vm.expectRevert(INVALID_GRACE_PERIOD_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(creator, fxGenArtProxy, uint48(ONE_DAY - 1), BASE_URI);
    }

    function test_RevertsWhen_InvalidOwner() public {
        vm.expectRevert(INVALID_OWNER_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(address(0), fxGenArtProxy, uint48(ONE_DAY), BASE_URI);
    }

    function test_RevertsWhen_InvalidToken() public {
        vm.expectRevert(INVALID_TOKEN_ERROR);
        fxMintTicketProxy = fxTicketFactory.createTicket(creator, address(0), uint48(ONE_DAY), BASE_URI);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                SET IMPLEMENTATION
    //////////////////////////////////////////////////////////////////////////*/

    function testSetImplementation() public {
        vm.prank(fxIssuerFactory.owner());
        fxIssuerFactory.setImplementation(address(fxMintTicket721));
        assertEq(fxIssuerFactory.implementation(), address(fxMintTicket721));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        ticketId = 1;
    }
}
