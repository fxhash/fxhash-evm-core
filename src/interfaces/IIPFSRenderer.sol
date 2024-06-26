// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRenderer} from "src/interfaces/IRenderer.sol";

/**
 * @title IIPFSRenderer
 * @author fx(hash)
 * @notice Renderer for constructing offchain metadata of FxGenArt721 tokens pinned to IPFS
 */
interface IIPFSRenderer is IRenderer {
    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRenderer
     */
    function contractRegistry() external view returns (address);

    /**
     * @inheritdoc IRenderer
     */
    function contractURI() external view returns (string memory);

    /**
     * @notice Generates the metadata URL for a token ID
     * @param _contractAddr Address of the token contract
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     * @return URL of the JSON metadata
     */
    function getMetadataURL(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) external view returns (string memory);

    /**
     * @inheritdoc IRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
