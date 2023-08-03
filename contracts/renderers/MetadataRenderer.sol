// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {IMetadataRenderer} from "contracts/interfaces/IMetadataRenderer.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MetadataRenderer
 * @notice See the documentation in {IMetadataRenderer}
 */
contract MetadataRenderer is IMetadataRenderer {
    using Strings for uint256;
    address public immutable ethfsFileStorage;
    address public immutable scriptyStorage;
    address public immutable scriptyBuilder;

    constructor(address _ethfsFileStorage, address _scriptyStorage, address _scriptyBuilder) {
        ethfsFileStorage = _ethfsFileStorage;
        scriptyStorage = _scriptyStorage;
        scriptyBuilder = _scriptyBuilder;
    }

    function renderOnchain(uint256 _tokenId) public pure returns (string memory) {
        return _tokenId.toString();
    }

    function renderOffchain(uint256 _tokenId) public pure returns (string memory) {
        return _tokenId.toString();
    }
}
