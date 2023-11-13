// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HTMLRequest} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";
import {IRenderer} from "src/interfaces/IRenderer.sol";

/**
 * @title IScriptyRenderer
 * @author fx(hash)
 * @notice Renderer for building onchain metadata of FxGenArt721 tokens using Scripty.sol
 */
interface IScriptyRenderer is IRenderer {
    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IRenderer
     */
    function contractURI(string memory _defaultURI) external view returns (string memory);

    /**
     * @notice Returns the address of ETHFSFileStorage contract
     */
    function ethfsFileStorage() external view returns (address);

    /**
     * @notice Builds the encoded HTML request for header and body tags
     * @param _tokenId ID of the token
     * @param _seed Hash of the randomly generated fxHash seed
     * @param _fxParams Bytes value of user-input params
     * @param _htmlRequest HTMLRequest of script
     */
    function getEncodedHTML(
        uint256 _tokenId,
        bytes32 _seed,
        bytes memory _fxParams,
        HTMLRequest memory _htmlRequest
    ) external view returns (bytes memory);

    /**
     * @notice Generates the image URI of a token ID
     * @param _defaultURI Fallback URI
     * @param _baseURI URI of the content identifier
     * @param _tokenId ID of the token
     */
    function getImageURI(
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) external view returns (string memory);

    /**
     * @notice Renders the token scripts onchain
     * @param _tokenId ID of the token
     * @param _seed Hash of the randomly generated fxHash seed
     * @param _fxParams Bytes value of user-input params
     * @param _animationURL HTMLRequest of token animation
     * @param _attributes HTMLRequest of token attributes
     */
    function renderOnchain(
        uint256 _tokenId,
        bytes32 _seed,
        bytes calldata _fxParams,
        HTMLRequest calldata _animationURL,
        HTMLRequest calldata _attributes
    ) external view returns (bytes memory);

    /**
     * @notice Returns the address of ScriptyBuilder contract
     */
    function scriptyBuilder() external view returns (address);

    /**
     * @notice Returns the address of ScriptyStorage contract
     */
    function scriptyStorage() external view returns (address);

    /**
     * @inheritdoc IRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
}
