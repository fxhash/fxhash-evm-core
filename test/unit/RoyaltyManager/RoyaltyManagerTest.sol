// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";
import {IRoyaltyManager} from "src/interfaces/IRoyaltyManager.sol";
import {MockRoyaltyManager} from "test/mocks/MockRoyaltyManager.sol";

contract RoyaltyManagerTest is BaseTest {
    // State
    RoyaltyManager internal royaltyManager;

    // Custom Errors
    bytes4 INVALID_ROYALTY_CONFIG_ERROR = IRoyaltyManager.InvalidRoyaltyConfig.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IRoyaltyManager.LengthMismatch.selector;
    bytes4 MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR =
        IRoyaltyManager.MoreThanOneRoyaltyReceiver.selector;
    bytes4 NON_EXISTENT_TOKEN_ERROR = IRoyaltyManager.NonExistentToken.selector;
    bytes4 OVER_MAX_BASIS_POINTS_ALLOWED_ERROR = IRoyaltyManager.OverMaxBasisPointsAllowed.selector;

    function setUp() public virtual override {
        royaltyManager = new MockRoyaltyManager();
    }
}
