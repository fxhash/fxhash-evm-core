// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";

contract MockRoyaltyManager is RoyaltyManager {
    mapping(uint256 => bool) public tokens;

    function setTokenExists(uint256 _tokenId, bool exists) external {
        tokens[_tokenId] = exists;
    }

    function setBaseRoyalties(address[] calldata _receivers, uint96[] calldata _basisPoints) external {
        _setBaseRoyalties(_receivers, _basisPoints);
    }

    function setTokenRoyalties(uint256 _id, address[] calldata _receivers, uint96[] calldata _basisPoints) external {
        _setTokenRoyalties(_id, _receivers, _basisPoints);
    }

    function _exists(uint256 _tokenId) internal view override returns (bool) {
        return tokens[_tokenId];
    }
}
