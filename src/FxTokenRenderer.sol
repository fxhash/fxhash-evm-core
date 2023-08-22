// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {IFxTokenRenderer} from "src/interfaces/IFxTokenRenderer.sol";
import {
    IScriptyBuilderV2,
    HTMLRequest,
    HTMLTagType,
    HTMLTag
} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

/**
 * @title FxTokenRenderer
 * @notice See the documentation in {IFxTokenRenderer}
 */
contract FxTokenRenderer is IFxTokenRenderer {
    using Strings for uint256;

    address public immutable ethfsFileStorage;
    address public immutable scriptyStorage;
    address public immutable scriptyBuilder;

    constructor(address _ethfsFileStorage, address _scriptyStorage, address _scriptyBuilder) {
        ethfsFileStorage = _ethfsFileStorage;
        scriptyStorage = _scriptyStorage;
        scriptyBuilder = _scriptyBuilder;
    }

    function renderOnchain(
        uint256 _tokenId,
        bytes32 _seed,
        bytes calldata _fxParams,
        HTMLRequest calldata _animation,
        HTMLRequest calldata _attributes
    ) public view returns (bytes memory) {
        bytes memory animation = getEncodedHTML(_tokenId, _seed, _fxParams, _animation);
        bytes memory attributes = getEncodedHTML(_tokenId, _seed, _fxParams, _attributes);

        return
            abi.encodePacked('"animation_url":"', animation, '","attributes":["', attributes, '"]}');
    }

    function getEncodedHTML(
        uint256 _tokenId,
        bytes32 _seed,
        bytes calldata _fxParams,
        HTMLRequest calldata _htmlRequest
    ) public view returns (bytes memory) {
        HTMLTag[] memory headTags = new HTMLTag[](_htmlRequest.headTags.length);
        HTMLTag[] memory bodyTags = new HTMLTag[](
            _htmlRequest.bodyTags.length + 1
        );

        for (uint256 i; i < _htmlRequest.headTags.length; ++i) {
            headTags[i].tagOpen = _htmlRequest.headTags[i].tagOpen;
            headTags[i].tagContent = _htmlRequest.headTags[i].tagContent;
            headTags[i].tagClose = _htmlRequest.headTags[i].tagClose;
        }

        for (uint256 i; i < _htmlRequest.bodyTags.length; ++i) {
            bodyTags[i].name = _htmlRequest.bodyTags[i].name;
            bodyTags[i].tagType = _htmlRequest.bodyTags[i].tagType;
            bodyTags[i].tagOpen = _htmlRequest.bodyTags[i].tagOpen;
            bodyTags[i].tagClose = _htmlRequest.bodyTags[i].tagClose;
            bodyTags[i].contractAddress = _htmlRequest.bodyTags[i].contractAddress;
        }

        bodyTags[bodyTags.length].tagType = HTMLTagType.script;
        bodyTags[bodyTags.length].tagContent = _seed != bytes32(0)
            ? _getSeedContent(_tokenId, _seed)
            : _getParamsContent(_tokenId, _fxParams);

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        return IScriptyBuilderV2(scriptyBuilder).getEncodedHTML(htmlRequest);
    }

    function _getSeedContent(uint256 _tokenId, bytes32 _seed)
        internal
        pure
        returns (bytes memory)
    {
        string memory tokenId = _tokenId.toString();
        string memory seed = uint256(_seed).toHexString(32);
        return
            abi.encodePacked('let tokenData = {"tokenId": "', tokenId, '", "seed": "', seed, '"};');
    }

    function _getParamsContent(uint256 _tokenId, bytes calldata _fxParams)
        internal
        pure
        returns (bytes memory)
    {
        string memory tokenId = _tokenId.toString();
        return abi.encodePacked(
            'let tokenData = {"tokenId": "', tokenId, '", "fxParams": "', _fxParams, '"};'
        );
    }
}
