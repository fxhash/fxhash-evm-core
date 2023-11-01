// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract FxContractRegistryTest is BaseTest {
    // State
    bytes32 internal hashedName;

    // Errors
    bytes4 INPUT_EMPTY_ERROR = IFxContractRegistry.InputEmpty.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IFxContractRegistry.LengthMismatch.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        configInfo.lockTime = LOCK_TIME;
        configInfo.referrerShare = REFERRER_SHARE;
        configInfo.defaultMetadata = DEFAULT_METADATA;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    SET CONFIG
    //////////////////////////////////////////////////////////////////////////*/

    function testSetConfig() public {
        RegistryLib.setConfig(fxContractRegistry.owner(), fxContractRegistry, configInfo);
        (lockTime, referrerShare, defaultMetadata) = fxContractRegistry.configInfo();

        assertEq(lockTime, configInfo.lockTime);
        assertEq(referrerShare, configInfo.referrerShare);
        assertEq(defaultMetadata, configInfo.defaultMetadata);
    }
}
