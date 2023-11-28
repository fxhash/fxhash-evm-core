// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FxContractRegistryTest is BaseTest {
    // State
    bytes32 internal hashedName;

    // Errors
    bytes4 LENGTH_MISMATCH_ERROR = IFxContractRegistry.LengthMismatch.selector;
    bytes4 LENGTH_ZERO_ERROR = IFxContractRegistry.LengthZero.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SET CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    function testSetConfig() public {
        RegistryLib.setConfig(fxContractRegistry.owner(), fxContractRegistry, configInfo);
        (
            feeReceiver,
            primaryFeeAllocation,
            secondaryFeeAllocation,
            lockTime,
            referrerShare,
            defaultMetadataURI
        ) = fxContractRegistry.configInfo();

        assertEq(lockTime, configInfo.lockTime);
        assertEq(referrerShare, configInfo.referrerShare);
        assertEq(defaultMetadataURI, configInfo.defaultMetadataURI);
        assertEq(primaryFeeAllocation, PRIMARY_FEE_ALLOCATION);
        assertEq(secondaryFeeAllocation, SECONDARY_FEE_ALLOCATION);
        assertEq(feeReceiver, admin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        configInfo.lockTime = LOCK_TIME;
        configInfo.referrerShare = REFERRER_SHARE;
        configInfo.defaultMetadataURI = DEFAULT_METADATA_URI;
    }
}
