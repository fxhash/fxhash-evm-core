// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {GenArtInfo, MetadataInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";

/**
 * @title IRenderer
 * @notice Interface for FxGenArt721 Tokens to interact with Renderers
 */
interface IRenderer {
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
