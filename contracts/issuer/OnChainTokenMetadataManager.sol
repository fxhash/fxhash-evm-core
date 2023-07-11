// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import {IScriptyBuilder, WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import "contracts/libs/LibIssuer.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract OnChainTokenMetadataManager is IOnChainTokenMetadataManager {
    IScriptyBuilder private scriptyAddress;

    constructor(address _scriptyAddress) {
        scriptyAddress = IScriptyBuilder(_scriptyAddress);
    }

    function getOnChainURI(
        bytes calldata _metadata,
        bytes calldata _onChainData
    ) external view returns (string memory) {
        TokenAttribute[] memory tokenMetadata = abi.decode(_metadata, (TokenAttribute[]));
        WrappedScriptRequest[] memory request = abi.decode(_onChainData, (WrappedScriptRequest[]));

        uint256 bufferSize = scriptyAddress.getBufferSizeForEncodedHTMLWrapped(request);

        bytes memory base64EncodedHTMLDataURI = scriptyAddress.getEncodedHTMLWrapped(
            request,
            bufferSize
        );

        string memory metadata = string.concat(
            '{"',
            tokenMetadata[0].key,
            '":"',
            tokenMetadata[0].value,
            '"'
        );

        for (uint256 i = 1; i < tokenMetadata.length; i++) {
            metadata = string.concat(
                metadata,
                ',"',
                tokenMetadata[i].key,
                '":"',
                tokenMetadata[i].value,
                '"'
            );
        }

        bytes memory packedMetadata = abi.encodePacked(
            metadata,
            ',"animation_url":"',
            base64EncodedHTMLDataURI,
            '"}'
        );

        return
            string(
                abi.encodePacked("data:application/json;base64,", Base64.encode(packedMetadata))
            );
    }
}
