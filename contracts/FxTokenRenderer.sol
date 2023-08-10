// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {IFxTokenRenderer} from "contracts/interfaces/IFxTokenRenderer.sol";
import {
    IScriptyBuilderV2,
    HTMLRequest,
    HTMLTagType,
    HTMLTag
} from "scripty.sol/contracts/scripty/interfaces/IScriptyBuilderV2.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

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

    function renderMetadata(
        uint256 _tokenId,
        bytes32 _seed,
        bytes calldata _fxParams,
        HTMLRequest calldata _animationURL,
        HTMLRequest calldata _attributes
    ) public view returns (string memory) {
        HTMLTag[] memory headTags = new HTMLTag[](1);

        // <link rel="stylesheet" href="data:text/css;base64,[fullSizeCanvas.css, base64 encoded]">
        headTags[0].name = "fullSizeCanvas.css";
        headTags[0].tagOpen = '<link rel="stylesheet" href="data:text/css;base64,';
        headTags[0].tagClose = '">';
        headTags[0].contractAddress = ethfsFileStorage;

        HTMLTag[] memory bodyTags = new HTMLTag[](3);
        bodyTags[0].name = "p5-v1.5.0.min.js.gz";
        bodyTags[0].tagType = HTMLTagType.scriptGZIPBase64DataURI; // <script
            // type="text/javascript+gzip" src="data:text/javascript;base64,[script]"></script>
        bodyTags[0].contractAddress = ethfsFileStorage;

        bodyTags[1].name = "gunzipScripts-0.0.1.js";
        bodyTags[1].tagType = HTMLTagType.scriptBase64DataURI; // <script
            // src="data:text/javascript;base64,[script]"></script>
        bodyTags[1].contractAddress = ethfsFileStorage;

        bodyTags[2].name = "pointsAndLines";
        bodyTags[2].tagType = HTMLTagType.script; // <script>[script]</script>
        bodyTags[2].contractAddress = scriptyStorage;

        HTMLRequest memory htmlRequest;
        htmlRequest.headTags = headTags;
        htmlRequest.bodyTags = bodyTags;

        string memory name;
        string memory description;
        bytes memory base64EncodedHTMLDataURI =
            IScriptyBuilderV2(scriptyBuilder).getEncodedHTML(htmlRequest);

        bytes memory metadata = abi.encodePacked(
            '{"name":"',
            name,
            '","description":"',
            description,
            '","animation_url":"',
            base64EncodedHTMLDataURI,
            '"}'
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(metadata)));
    }
}
