// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IRenderer} from "src/interfaces/IRenderer.sol";

/**
 * @title IONCHFSRenderer
 * @author fx(hash)
 * @notice Renderer for constructing onchain metadata of FxGenArt721 tokens stored through ONCHFS
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
     * @notice Generates the animation URI for a token ID
     * @param _onchfsCID CID hash of onchfs animation data
     * @param _tokenId ID of the token
     * @param _minter Address of initial token owner
     * @param _seed Hash of randomly generated seed
     * @param _fxParams Random sequence of fixed-length bytes used as token input
     * @return URI of the animation pointer
     */
    function getAnimationURI(
        string memory _onchfsCID,
        uint256 _tokenId,
        address _minter,
        bytes32 _seed,
        bytes memory _fxParams
    ) external pure returns (string memory);

    /**
     * @notice Generates the attributes URI for a token ID
     * @param _contractAddr Address of the token contract
     * @param _defaultURI URI of offchain metadata
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     * @return URI of the attributes pointer
     */
    function getAttributesURI(
        address _contractAddr,
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) external pure returns (string memory);

    /**
     * @notice Generates the external URL for a token ID
     * @param _contractAddr Address of the token contract
     * @param _defaultURI URI of offchain metadata
     * @param _tokenId ID of the token
     * @return URL of the external token pointer
     */
    function getExternalURL(
        address _contractAddr,
        string memory _defaultURI,
        uint256 _tokenId
    ) external pure returns (string memory);

    /**
     * @notice Generates the image URI for a token ID
     * @param _contractAddr Address of the token contract
     * @param _defaultURI URI of offchain metadata
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     * @return URI of the image pointer
     */
    function getImageURI(
        address _contractAddr,
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) external pure returns (string memory);

    /**
     * @inheritdoc IRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
