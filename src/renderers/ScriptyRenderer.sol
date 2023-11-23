// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {LibIPFSEncoder} from "src/lib/LibIPFSEncoder.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {SSTORE2} from "sstore2/contracts/SSTORE2.sol";

import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IScriptyBuilderV2, HTMLRequest, HTMLTagType, HTMLTag} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";
import {IScriptyRenderer} from "src/interfaces/IScriptyRenderer.sol";

import {METADATA_ENDPOINT, THUMBNAIL_ENDPOINT} from "src/utils/Constants.sol";

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
    address public immutable contractRegistry;

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
     * @dev Initializes FxContractRegistry, ETHFSFileStorage, ScriptyStorage and ScriptyBuilder
     */
    constructor(
        address _contractRegistry,
        address _ethfsFileStorage,
        address _scriptyStorage,
        address _scriptyBuilder
    ) {
        contractRegistry = _contractRegistry;
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
    function contractURI() external view returns (string memory) {
        (, , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        string memory contractAddr = uint160(msg.sender).toHexString(20);
        return string.concat(defaultURI, contractAddr, METADATA_ENDPOINT);
    }

    /**
     * @inheritdoc IScriptyRenderer
     */
    function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory) {
        (, , string memory defaultURI) = IFxContractRegistry(contractRegistry).configInfo();
        (bytes memory baseCID, address onchainPointer, bytes32 seed, bytes memory fxParams) = abi.decode(
            _data,
            (bytes, address, bytes32, bytes)
        );
        string memory baseURI = LibIPFSEncoder.encodeURL(bytes32(baseCID));
        return _renderOnchain(msg.sender, defaultURI, baseURI, _tokenId, seed, fxParams, onchainPointer);
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
    function getImageURI(
        address _contractAddr,
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId
    ) public pure returns (string memory) {
        string memory contractAddr = uint160(_contractAddr).toHexString(20);
        string memory imageURI = string.concat("/", _tokenId.toString(), THUMBNAIL_ENDPOINT);
        return
            (bytes(_baseURI).length == 0)
                ? string.concat(_defaultURI, contractAddr, imageURI)
                : string.concat(_baseURI, imageURI);
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

    function _renderOnchain(
        address _token,
        string memory _defaultURI,
        string memory _baseURI,
        uint256 _tokenId,
        bytes32 _seed,
        bytes memory _fxParams,
        address _onchainPointer
    ) internal view returns (string memory) {
        bytes memory onchainData = SSTORE2.read(_onchainPointer);
        (HTMLRequest memory animation, HTMLRequest memory attributes) = abi.decode(
            onchainData,
            (HTMLRequest, HTMLRequest)
        );
        string memory imageURI = getImageURI(_token, _defaultURI, _baseURI, _tokenId);
        bytes memory animationURI = getEncodedHTML(_tokenId, _seed, _fxParams, animation);
        bytes memory attributesList = getEncodedHTML(_tokenId, _seed, _fxParams, attributes);

        return
            string(
                abi.encodePacked(
                    '"image":"',
                    imageURI,
                    '"animation_url":"',
                    string(abi.encodePacked("data:application/json;base64,", Base64.encode(animationURI))),
                    '", "attributes":["',
                    string(abi.encodePacked(Base64.encode(attributesList))),
                    '"]}'
                )
            );
    }
}
