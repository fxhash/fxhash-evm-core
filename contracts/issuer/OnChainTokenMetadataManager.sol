// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import {IScriptyBuilder, WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import "contracts/libs/LibIssuer.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract OnChainTokenMetadataManager is IOnChainTokenMetadataManager {
    address private scriptyAddress;
    uint256 private scriptyBufferSize;

    constructor(address _scriptyAddress, uint256 _scriptyBufferSize) {
        scriptyAddress = _scriptyAddress;
        scriptyBufferSize = _scriptyBufferSize;
    }

    function getOnChainURI(
        bytes calldata _metadata,
        bytes calldata _onChainData
    ) external view returns (string memory) {
        TokenAttribute[] memory tokenMetadata = abi.decode(
            _metadata,
            (TokenAttribute[])
        );
        bytes memory base64EncodedHTMLDataURI = IScriptyBuilder(scriptyAddress)
            .getEncodedHTMLWrapped(
                abi.decode(_onChainData, (WrappedScriptRequest[])),
                scriptyBufferSize
            );

        string memory metadata = string.concat(
            '{"',
            tokenMetadata[0].key,
            '":"',
            tokenMetadata[0].key,
            '"'
        );
        for (uint256 i = 1; i < tokenMetadata.length; i++) {
            metadata = string.concat(
                metadata,
                ',"',
                tokenMetadata[i].key,
                '":"',
                tokenMetadata[i].key,
                '"'
            );
        }
        metadata = string.concat(
            metadata,
            ',"animation_url":"',
            string(base64EncodedHTMLDataURI),
            '"}'
        );
        bytes memory packedMetadata = abi.encodePacked(metadata);

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(packedMetadata)
                )
            );
    }
}
