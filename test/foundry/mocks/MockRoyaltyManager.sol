// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {RoyaltyManager} from "contracts/gentk/RoyaltyManager.sol";

contract MockRoyaltyManager is RoyaltyManager {
    mapping(uint256 => bool) public tokens;

    function setTokenExists(uint256 tokenId, bool exists) external {
        tokens[tokenId] = exists;
    }

    function _exists(uint256 _tokenId) internal view override returns (bool) {
        return tokens[_tokenId];
    }

    function supportsInterface(bytes4) public pure override returns (bool) {
        return true;
    }
}
