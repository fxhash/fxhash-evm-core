// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RoyaltyManager} from "contracts/gentk/RoyaltyManager.sol";

contract MockRoyaltyManager is RoyaltyManager {
    function deleteBaseRoyalty() external {
        _resetBaseRoyalty();
    }

    function deleteTokenRoyalty(uint256 _tokenId) external {
        _resetTokenRoyalty(_tokenId);
    }
}
