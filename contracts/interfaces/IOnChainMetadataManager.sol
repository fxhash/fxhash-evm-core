// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

struct TokenAttribute {
    string key;
    string value;
}

interface IOnChainMetadataManager {
    function getOnChainURI(
        bytes calldata _metadata,
        bytes calldata _onChainScripts
    ) external view returns (string memory);
}
