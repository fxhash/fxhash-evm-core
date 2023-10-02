// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";

contract MockRoyaltyManager is RoyaltyManager {
    mapping(uint256 => bool) public tokens;

    function setTokenExists(uint256 tokenId, bool exists) external {
        tokens[tokenId] = exists;
    }

    function _exists(uint256 _tokenId) internal view override returns (bool) {
        return tokens[_tokenId];
    }
}
