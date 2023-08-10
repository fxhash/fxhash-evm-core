// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {FxRoyaltyManager} from "contracts/FxRoyaltyManager.sol";

contract MockRoyaltyManager is FxRoyaltyManager {
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
