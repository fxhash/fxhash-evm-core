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
        _configureInfo(admin, FEE_ALLOCATION, LOCK_TIME, REFERRER_SHARE, DEFAULT_METADATA_URI);
        _configureRoyalties();
        _initializeState();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        projectId = 1;
        initInfo.primaryReceiver = address(this);
        initInfo.randomizer = address(pseudoRandomizer);
        initInfo.renderer = address(ipfsRenderer);
    }
}
