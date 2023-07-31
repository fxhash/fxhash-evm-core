// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IOnChainTokenMetadataManager {
    struct TokenAttribute {
        string key;
        string value;
    }

    function getOnChainURI(
        bytes calldata _metadata,
        bytes calldata _onChainScripts
    ) external view returns (string memory);
}
