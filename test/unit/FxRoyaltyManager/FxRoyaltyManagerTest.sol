// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

import {FxRoyaltyManager} from "src/FxRoyaltyManager.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";
import {MockFxRoyaltyManager} from "test/mocks/MockFxRoyaltyManager.sol";

contract FxRoyaltyManagerTest is BaseTest {
    // State
    uint256 internal tokenId;
    FxRoyaltyManager internal royaltyManager;

    // Custom Errors
    bytes4 INVALID_ROYALTY_CONFIG_ERROR = IFxRoyaltyManager.InvalidRoyaltyConfig.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IFxRoyaltyManager.LengthMismatch.selector;
    bytes4 MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR =
        IFxRoyaltyManager.MoreThanOneRoyaltyReceiver.selector;
    bytes4 NON_EXISTENT_TOKEN_ERROR = IFxRoyaltyManager.NonExistentToken.selector;
    bytes4 OVER_MAX_BASIS_POINTS_ALLOWED_ERROR =
        IFxRoyaltyManager.OverMaxBasisPointsAllowed.selector;

    function setUp() public virtual override {
        royaltyManager = new MockFxRoyaltyManager();
    }
}
