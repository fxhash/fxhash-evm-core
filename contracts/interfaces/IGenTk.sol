// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IGenTk {
    struct TokenParams {
        uint256 tokenId;
        address receiver;
        uint256 iteration;
        bytes inputBytes;
        string metadata;
    }

    struct TokenData {
        uint256 iteration;
        address minter;
        bool assigned;
        bytes inputBytes;
    }

    struct TokenMetadata {
        uint256 tokenId;
        string metadata;
    }

    struct OnChainTokenMetadata {
        uint256 tokenId;
        bytes metadata;
    }

    error NotFxHashAdmin();
    error NotIssuer();
    error NotSigner();
    error TokenUndefined();

    event TokenMinted(TokenParams _params);
    event TokenMetadataAssigned(TokenMetadata[] _params);
    event OnChainTokenMetadataAssigned(OnChainTokenMetadata[] _params);

    function assignMetadata(TokenMetadata[] calldata _metadata) external;

    function assignOnChainMetadata(OnChainTokenMetadata[] calldata _params) external;

    function mint(TokenParams calldata _params) external;

    function setConfigManager(address _configManager) external;
}
