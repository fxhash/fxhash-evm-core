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
        bytes inputBytes;
        address minter;
        bool assigned;
    }

    struct TokenMetadata {
        uint256 tokenId;
        string metadata;
    }

    struct OnChainTokenMetadata {
        uint256 tokenId;
        bytes metadata;
    }

    error NotAdmin();
    error NotIssuer();
    error NotSigner();
    error TokenUndefined();

    event TokenMinted(TokenParams _params);
    event TokenMetadataAssigned(TokenMetadata[] _params);
    event OnChainTokenMetadataAssigned(OnChainTokenMetadata[] _params);

    function mint(TokenParams calldata _params) external;
}
