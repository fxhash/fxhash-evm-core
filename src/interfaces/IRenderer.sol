// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IRenderer
 * @notice Interface for FxGenArt721 Tokens to interact with Renderers
 */
interface IRenderer {
    /**
     * @notice Returns the URI for a given token ID
     * @param _tokenId The token ID
     * @param _data Additional data that may be used to construct the token URI
     * @return The URI for the token
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
