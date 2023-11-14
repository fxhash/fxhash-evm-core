// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import {GenArtInfo, MetadataInfo} from "src/interfaces/IFxGenArt721.sol";
import {IScriptyBuilderV2, HTMLRequest, HTMLTagType, HTMLTag} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";
import {IScriptyRenderer} from "src/interfaces/IScriptyRenderer.sol";

/**
 * @title ScriptyRenderer
 * @author fx(hash)
 * @dev See the documentation in {IScriptyRenderer}
 */
contract ScriptyRenderer is IScriptyRenderer {
    using Strings for uint160;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IScriptyRenderer
     */
    address public immutable ethfsFileStorage;

    /**
     * @inheritdoc IScriptyRenderer
     */
    address public immutable scriptyBuilder;

    /**
     * @inheritdoc IScriptyRenderer
     */
    address public immutable scriptyStorage;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes ETHFSFileStorage, ScriptyStorage and ScriptyBuilder
     */
    constructor(address _ethfsFileStorage, address _scriptyStorage, address _scriptyBuilder) {
        ethfsFileStorage = _ethfsFileStorage;
        scriptyStorage = _scriptyStorage;
        scriptyBuilder = _scriptyBuilder;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IScriptyRenderer
     */
    function contractURI(string memory _defaultMetadataURI) external view returns (string memory) {
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(_defaultMetadataURI, contractAddr, "/metadata.json");
    }

    /**
     * @inheritdoc IScriptyRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (string memory defaultURI, MetadataInfo memory metadataInfo, GenArtInfo memory genArtInfo) = abi.decode(
            _data,
            (string, MetadataInfo, GenArtInfo)
        );
        (HTMLRequest memory animation, HTMLRequest memory attributes) = abi.decode(
            metadataInfo.onchainData,
            (HTMLRequest, HTMLRequest)
        );
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(metadataInfo.baseURI));
        string memory imageURI = imageURI(defaultURI, baseURI, _tokenId);
        bytes memory animationURI = renderOnchain(
            _tokenId,
            genArtInfo.seed,
            genArtInfo.fxParams,
            animation,
            attributes
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(animationURI)));
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IScriptyRenderer
     */
    function getEncodedHTML(
        uint256 _tokenId,
        bytes32 _seed,
        bytes memory _fxParams,
        HTMLRequest memory _htmlRequest
    ) public view returns (bytes memory) {
        HTMLTag[] memory headTags = new HTMLTag[](_htmlRequest.headTags.length);
        HTMLTag[] memory bodyTags = new HTMLTag[](_htmlRequest.bodyTags.length + 1);

        for (uint256 i; i < _htmlRequest.headTags.length; ) {
            headTags[i].tagOpen = _htmlRequest.headTags[i].tagOpen;
            headTags[i].tagContent = _htmlRequest.headTags[i].tagContent;
            headTags[i].tagClose = _htmlRequest.headTags[i].tagClose;
            unchecked {
                ++i;
            }
        }

        for (uint256 i; i < _htmlRequest.bodyTags.length; ) {
            bodyTags[i].name = _htmlRequest.bodyTags[i].name;
            bodyTags[i].tagType = _htmlRequest.bodyTags[i].tagType;
            bodyTags[i].tagOpen = _htmlRequest.bodyTags[i].tagOpen;
            bodyTags[i].tagClose = _htmlRequest.bodyTags[i].tagClose;
            bodyTags[i].contractAddress = _htmlRequest.bodyTags[i].contractAddress;
            unchecked {
                ++i;
            }
        }

        bodyTags[bodyTags.length - 1].tagType = HTMLTagType.script;
        bodyTags[bodyTags.length - 1].tagContent = _seed != bytes32(0)
            ? _getSeedContent(_tokenId, _seed)
            : _getParamsContent(_tokenId, _fxParams);

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        return IScriptyBuilderV2(scriptyBuilder).getEncodedHTML(htmlRequest);
    }

    /**
     * @dev IScriptyRenderer
     */
    function imageURI(
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) public view returns (string memory) {
        string memory contractAddr = uint160(address(this)).toHexString(20);
        string memory imageThumbnailURI = string.concat("/", _tokenId.toString(), "/thumbnail.json");
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(_defaultURI, contractAddr, imageThumbnailURI)
                : string.concat(_baseURI, imageThumbnailURI);
    }

    /**
     * @inheritdoc IScriptyRenderer
     */
    function renderOnchain(
        uint256 _tokenId,
        bytes32 _seed,
        bytes memory _fxParams,
        HTMLRequest memory _animation,
        HTMLRequest memory _attributes
    ) public view returns (bytes memory) {
        bytes memory animation = getEncodedHTML(_tokenId, _seed, _fxParams, _animation);
        bytes memory attributes = getEncodedHTML(_tokenId, _seed, _fxParams, _attributes);
        return abi.encodePacked('"animation_url":"', animation, '", "attributes":["', attributes, '"]}');
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Gets the params content for tokens minted with fxParams
     */
    function _getParamsContent(uint256 _tokenId, bytes memory _fxParams) internal pure returns (bytes memory) {
        string memory tokenId = _tokenId.toString();
        return abi.encodePacked('let tokenData = {"tokenId": "', tokenId, '", "fxParams": "', _fxParams, '"};');
    }

    /**
     * @dev Gets the seed content for randomly minted tokens
     */
    function _getSeedContent(uint256 _tokenId, bytes32 _seed) internal pure returns (bytes memory) {
        string memory tokenId = _tokenId.toString();
        string memory seed = uint256(_seed).toHexString(32);
        return abi.encodePacked('let tokenData = {"tokenId": "', tokenId, '", "seed": "', seed, '"};');
    }
}
