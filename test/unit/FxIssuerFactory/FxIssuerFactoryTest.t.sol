// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";
import {IFxIssuerFactory, ConfigInfo} from "src/interfaces/IFxIssuerFactory.sol";

contract FxIssuerFactoryTest is BaseTest {
    // State
    uint128 internal feeShare;
    uint128 internal lockTime;
    string internal defaultMetadata;

    // Custom Errors
    bytes4 INVALID_OWNER_ERROR = IFxIssuerFactory.InvalidOwner.selector;
    bytes4 INVALID_PRIMARY_RECEIVER_ERROR = IFxIssuerFactory.InvalidPrimaryReceiver.selector;

    function setUp() public virtual override {
        super.setUp();
        projectId = 1;
    }
}
