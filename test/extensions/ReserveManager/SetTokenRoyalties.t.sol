// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "test/extensions/RoyaltyManager/RoyaltyManagerTest.sol";

contract SetTokenRoyaltiesTest is RoyaltyManagerTest {
    address internal royaltyReceiver;
    uint96 internal basisPoint;

    function setUp() public override {
        super.setUp();
        royaltyManager.setTokenExists(tokenId, true);
        royaltyReceivers.push(payable(susan));
        allocations.push(1);
    }

    function test_SetTokenRoyalties() public {
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceiver, basisPoint);
    }

    function test_RevertsWhen_NonExistentToken() public {
        tokenId = 2;
        vm.expectRevert(abi.encodeWithSelector(NON_EXISTENT_TOKEN_ERROR));
        royaltyManager.setTokenRoyalties(tokenId, royaltyReceiver, basisPoint);
    }
}
