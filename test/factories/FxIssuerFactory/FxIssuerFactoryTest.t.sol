// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FxIssuerFactoryTest is BaseTest {
    // Errors
    bytes4 INVALID_OWNER_ERROR = IFxIssuerFactory.InvalidOwner.selector;
    bytes4 INVALID_PRIMARY_RECEIVER_ERROR = IFxIssuerFactory.InvalidPrimaryReceiver.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();

        _configureInfo(
            admin,
            SECONDARY_FEE_ALLOCATION,
            PRIMARY_FEE_ALLOCATION,
            LOCK_TIME,
            REFERRER_SHARE,
            DEFAULT_METADATA_URI,
            EXTERNAL_URI
        );
        _initializeState();
        _mockMinter(admin);
        _configureRoyalties();
        _configureProject(MINT_ENABLED, MAX_SUPPLY);
        _configureMinter(minter, RESERVE_START_TIME, RESERVE_END_TIME, MINTER_ALLOCATION, abi.encode(PRICE));
        RegistryLib.grantRole(admin, fxRoleRegistry, MINTER_ROLE, minter);
        _configureInit(NAME, SYMBOL, address(pseudoRandomizer), address(ipfsRenderer), tagIds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        projectId = 1;
        initInfo.randomizer = address(pseudoRandomizer);
        initInfo.renderer = address(ipfsRenderer);
    }
}
