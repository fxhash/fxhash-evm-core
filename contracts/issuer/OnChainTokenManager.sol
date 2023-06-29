// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IScriptyBuilder, WrappedScriptRequest} from "scripty.sol/contracts/scripty/IScriptyBuilder.sol";
import "contracts/libs/LibIssuer.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "hardhat/console.sol";

contract OnChainTokenManager {
    struct TokenAttribute {
        string key;
        string value;
    }

    struct TokenMetadata {
        string name;
        string description;
        string image;
        string animationUrl;
        TokenAttribute[] attributes;
    }

    address private scriptyAddress;
    uint256 private scriptyBufferSize;

    constructor(address _scriptyAddress, uint256 _scriptyBufferSize) {
        scriptyAddress = _scriptyAddress;
        scriptyBufferSize = _scriptyBufferSize;
    }

    function getOnChainURI(
        LibIssuer.IssuerData memory issuerData
    ) external view returns (string memory) {
        TokenMetadata memory tokenMetadata = abi.decode(
            issuerData.metadata,
            (TokenMetadata)
        );
        bytes memory base64EncodedHTMLDataURI = IScriptyBuilder(scriptyAddress)
            .getEncodedHTMLWrapped(
                abi.decode(issuerData.onChainData, (WrappedScriptRequest[])),
                scriptyBufferSize
            );

        bytes memory metadata = abi.encodePacked(
            string.concat(
                '{"name":"',
                tokenMetadata.name,
                '", "description":"',
                tokenMetadata.description,
                '","animation_url":"',
                string(base64EncodedHTMLDataURI),
                '"}'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(metadata)
                )
            );
    }
}
