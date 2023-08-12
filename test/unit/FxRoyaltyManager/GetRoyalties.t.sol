// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {FxRoyaltyManagerTest} from "test/unit/FxRoyaltyManager/FxRoyaltyManager.t.sol";
import {MAX_ROYALTY_BASISPOINTS} from "src/utils/Constants.sol";
import {IFxRoyaltyManager} from "src/interfaces/IFxRoyaltyManager.sol";

contract GetRoyalties is FxRoyaltyManagerTest {
    function setUp() public override {
        super.setUp();
        royaltyReceivers.push(payable(alice));
        royaltyReceivers.push(payable(bob));
        royaltyReceivers.push(payable(eve));

        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
        basisPoints.push(MAX_ROYALTY_BASISPOINTS);
    }

    function test_getRoyalties() public {
        royaltyManager.setBaseRoyalties(royaltyReceivers, basisPoints);
        address payable[] memory receivers;
        uint256[] memory bps;
        (receivers, bps) = royaltyManager.getRoyalties(tokenId);
        assertEq(receivers.length, royaltyReceivers.length, "accounts mismatch");
        assertEq(basisPoints.length, bps.length, "Basispoint mismatch");
    }
}
