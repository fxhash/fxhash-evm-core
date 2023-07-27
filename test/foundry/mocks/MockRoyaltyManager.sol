// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {RoyaltyManager} from "contracts/gentk/RoyaltyManager.sol";

contract MockRoyaltyManager is RoyaltyManager {
    mapping(uint256 => bool) public tokens;

    function setTokenExists(uint256 tokenId, bool exists) external {
        tokens[tokenId] = exists;
    }

    function deleteBaseRoyalty() external {
        _resetBaseRoyalty();
    }

    function deleteTokenRoyalty(uint256 _tokenId) external {
        _resetTokenRoyalty(_tokenId);
    }

    function _exists(uint256 _tokenId) internal view override returns (bool) {
        return tokens[_tokenId];
    }
}
