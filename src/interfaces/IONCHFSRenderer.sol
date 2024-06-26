// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRenderer} from "src/interfaces/IRenderer.sol";

/**
 * @title IONCHFSRenderer
 * @author fx(hash)
 * @notice Renderer for reconstructing metadata of FxGenArt721 tokens stored onchain through ONCHFS
 */
interface IONCHFSRenderer is IRenderer {
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
     * @notice Generates the animation URL for a token ID
     * @param _onchfsCID CID hash of token animation
     * @param _tokenId ID of the token
     * @param _minter Address of initial token owner
     * @param _seed Hash of randomly generated seed
     * @param _fxParams Random sequence of fixed-length bytes used as token input
     * @return URL of the animation pointer
     */
    function getAnimationURL(
        bytes32 _onchfsCID,
        uint256 _tokenId,
        address _minter,
        bytes32 _seed,
        bytes memory _fxParams
    ) external pure returns (string memory);

    /**
     * @notice Generates the list of attributes for a token ID
     * @param _contractAddr Address of the token contract
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     * @return List of token attributes
     */
    function getAttributes(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) external view returns (string memory);

    /**
     * @notice Generates the external URL for a token ID
     * @param _contractAddr Address of the token contract
     * @param _tokenId ID of the token
     * @return URL of the external token pointer
     */
    function getExternalURL(address _contractAddr, uint256 _tokenId) external view returns (string memory);

    /**
     * @notice Generates the image URL for a token ID
     * @param _contractAddr Address of the token contract
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     * @return URL of the image pointer
     */
    function getImageURL(
        address _contractAddr,
        string memory _baseURI,
        uint256 _tokenId
    ) external view returns (string memory);

    /**
     * @inheritdoc IRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
