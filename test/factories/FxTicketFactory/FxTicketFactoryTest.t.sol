// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxTicketFactoryTest is BaseTest {
    // Errors
    bytes4 INVALID_GRACE_PERIOD_ERROR = IFxTicketFactory.InvalidGracePeriod.selector;
    bytes4 INVALID_OWNER_ERROR = IFxTicketFactory.InvalidOwner.selector;
    bytes4 INVALID_REDEEMER_ERROR = IFxTicketFactory.InvalidRedeemer.selector;
    bytes4 INVALID_TOKEN_ERROR = IFxTicketFactory.InvalidToken.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockMinter(admin);
        _configureSplits();
        _configureRoyalties();
        _configureProject(ONCHAIN, MINT_ENABLED, MAX_SUPPLY, CONTRACT_URI);
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, minter);
        _createSplit();
        _configureInit(NAME, SYMBOL, primaryReceiver, address(pseudoRandomizer), address(scriptyRenderer), tagIds);
        _createProject();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        ticketId = 1;
    }
}
