// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ReserveInfo} from "contracts/interfaces/IBaseReserve.sol";
import {RoyaltyInfo} from "contracts/interfaces/IRoyaltyManager.sol";

/// @param projectInfo Project information
/// @param RoyaltyInfo Royalty splits of primary sales
/// @param minters Mapping of minter contract to enabled status
struct IssuerInfo {
    ProjectInfo projectInfo;
    RoyaltyInfo primarySplits;
    mapping(address => bool) minters;
}

/// @param enabled Active status of project
/// @param codexId ID of codex info
/// @param supply Maximum supply of tokens
/// @param metadata Bytes-encoded metadata of project
/// @param labels List of labels describing project
struct ProjectInfo {
    bool enabled;
    uint112 codexId;
    uint120 supply;
    bytes metadata;
    uint16[] labels;
}

/// @param fxParams Randon sequence of string bytes in fixed length
/// @param seed Hash of revealed seed
/// @param offChainPointer URI of offchain metadata pointer
/// @param onChainAttributes List of key value mappings of onchain metadata storage
struct TokenInfo {
    bytes fxParams;
    bytes32 seed;
    string offChainPointer;
    MetadataInfo[] onChainAttributes;
}

/// @param key Attribute key of JSON field
/// @param value Attribute value of JSON field
struct MetadataInfo {
    string key;
    string value;
}

interface IFxGenArt721 {
    error UnauthorizedCaller();

    event ProjectInitialized(
        ProjectInfo _projectInfo,
        RoyaltyInfo _primarySplits,
        address[] _minters,
        address payable[] _receivers,
        uint96[] _basisPoints
    );

    function initialize(
        address _owner,
        address _configManager,
        ProjectInfo calldata _projectInfo,
        RoyaltyInfo calldata _primarySplits,
        address[] calldata _minters,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) external;

    function config() external view returns (address);

    function genArtInfo(uint96 _tokenId) external view returns (TokenInfo memory);

    function tokenId() external view returns (uint96);
}
