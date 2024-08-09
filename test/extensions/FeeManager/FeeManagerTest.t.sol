// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

contract FeeManagerTest is BaseTest {
    // State
    CustomFee internal customFee;
    bool internal enabled;
    uint120 internal platformFee;
    uint64 internal mintPercentage;
    uint64 internal splitPercentage;

    // Errors
    bytes4 internal INVALID_PERCENTAGE_ERROR = IFeeManager.InvalidPercentage.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                     SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
    }
}
