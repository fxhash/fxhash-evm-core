// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title IRenderer
 * @author fx(hash)
 * @notice Interface for FxGenArt721 tokens to interact with renderers
 */
interface IRenderer {
    /**
     * @notice Gets the contact-level metadata for a project
     * @param _defaultURI Fallback URI
     * @return URI of the contract metadata
     */
    function contractURI(string memory _defaultURI) external view returns (string memory);

    /**
     * @notice Gets the metadata for a token
     * @param _tokenId ID of the token
     * @param _data Additional data used to construct metadata
     * @return URI of the token metadata
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
