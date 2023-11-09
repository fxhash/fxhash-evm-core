// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "test/BaseTest.t.sol";

contract RoyaltyManagerTest is BaseTest {
    // Errors
    bytes4 INVALID_ROYALTY_CONFIG_ERROR = IRoyaltyManager.InvalidRoyaltyConfig.selector;
    bytes4 LENGTH_MISMATCH_ERROR = IRoyaltyManager.LengthMismatch.selector;
    bytes4 MORE_THAN_ONE_ROYALTY_RECEIVER_ERROR = IRoyaltyManager.MoreThanOneRoyaltyReceiver.selector;
    bytes4 NON_EXISTENT_TOKEN_ERROR = IRoyaltyManager.NonExistentToken.selector;
    bytes4 OVER_MAX_BASIS_POINTS_ALLOWED_ERROR = IRoyaltyManager.OverMaxBasisPointsAllowed.selector;

    function setUp() public virtual override {
        _initializeState();
        _mockRoyaltyManager(admin);
    }

    function _initializeState() internal override {
        super._initializeState();
        tokenId = 1;
    }

    function _mockRoyaltyManager(address _admin) internal prank(_admin) {
        royaltyManager = new MockRoyaltyManager();
    }
}
