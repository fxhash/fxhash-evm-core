// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/BaseTest.t.sol";

import {MockRoyaltyManager} from "test/mocks/MockRoyaltyManager.sol";
import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";

contract RoyaltyManagerTest is BaseTest {
    // Contracts
    MockRoyaltyManager internal royaltyManager;

    // Errors
    bytes4 INVALID_ROYALTY_CONFIG_ERROR = IRoyaltyManager.InvalidRoyaltyConfig.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IRoyaltyManager.LengthMismatch.selector;
    bytes4 MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR = IRoyaltyManager.MoreThanOneRoyaltyReceiver.selector;
    bytes4 NON_EXISTENT_TOKEN_ERROR = IRoyaltyManager.NonExistentToken.selector;
    bytes4 OVER_MAX_BASIS_POINTS_ALLOWED_ERROR = IRoyaltyManager.OverMaxBasisPointsAllowed.selector;

    /*//////////////////////////////////////////////////////////////////////////
                                    SETUP
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual override {
        super.setUp();
        _initializeState();
        _mockRoyaltyManager(admin);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    function _initializeState() internal override {
        super._initializeState();
        tokenId = 1;
    }

    function _mockRoyaltyManager(address _admin) internal prank(_admin) {
        royaltyManager = new MockRoyaltyManager();
    }
}
