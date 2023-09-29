// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {GenArtInfo, MetadataInfo, ProjectInfo} from "src/interfaces/IFxGenArt721.sol";

/// @title IFxRenderer
/// @notice Interface for FxGenArt721 Tokens to interact with Renderers
interface IFxRenderer {
    function tokenURI(
        uint256 _tokenId,
        ProjectInfo memory _projectInfo,
        MetadataInfo memory _metadataInfo,
        GenArtInfo memory _genArtInfo
    ) external returns (string memory);
}
