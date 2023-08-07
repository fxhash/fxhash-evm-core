// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721URIStorageUpgradeable, ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IContractRegistry} from "contracts/interfaces/IContractRegistry.sol";
import {IFxGenArt721, IssuerInfo, ProjectInfo, MetadataInfo, TokenInfo} from "contracts/interfaces/IFxGenArt721.sol";
import {IFxMetadata} from "contracts/interfaces/IFxMetadata.sol";
import {IRoleRegistry} from "contracts/interfaces/IRoleRegistry.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {RoyaltyManager} from "contracts/royalties/RoyaltyManager.sol";

import "contracts/utils/Constants.sol";

/**
 * @title FxGenArt721
 * @notice See the documentation in {IFxGenArt721}
 */
contract FxGenArt721 is
    IFxGenArt721,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    RoyaltyManager
{
    /// @inheritdoc IFxGenArt721
    uint96 public currentId;
    /// @inheritdoc IFxGenArt721
    address public contractRegistry;
    /// @inheritdoc IFxGenArt721
    address public roleRegistry;
    /// @inheritdoc IFxGenArt721
    address public metadata;
    /// @inheritdoc IFxGenArt721
    IssuerInfo public issuerInfo;
    /// @dev Internal mapping of token ID to TokenInfo
    mapping(uint96 => TokenInfo) internal _genArtInfo;

    // |-------------------------------------------------------------------------------------------|
    // |░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  STORAGE LAYOUT  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|
    // |--------------------|----------------------------------------------|------|--------|-------|
    // | _initialized       | uint8                                        | 0    | 0      | 1     |
    // | _initializing      | bool                                         | 0    | 1      | 1     |
    // | __gap              | uint256[50]                                  | 1    | 0      | 1600  |
    // | __gap              | uint256[50]                                  | 51   | 0      | 1600  |
    // | _name              | string                                       | 101  | 0      | 32    |
    // | _symbol            | string                                       | 102  | 0      | 32    |
    // | _owners            | mapping(uint256 => address)                  | 103  | 0      | 32    |
    // | _balances          | mapping(address => uint256)                  | 104  | 0      | 32    |
    // | _tokenApprovals    | mapping(uint256 => address)                  | 105  | 0      | 32    |
    // | _operatorApprovals | mapping(address => mapping(address => bool)) | 106  | 0      | 32    |
    // | __gap              | uint256[44]                                  | 107  | 0      | 1408  |
    // | _tokenURIs         | mapping(uint256 => string)                   | 151  | 0      | 32    |
    // | __gap              | uint256[49]                                  | 152  | 0      | 1568  |
    // | _owner             | address                                      | 201  | 0      | 20    |
    // | __gap              | uint256[49]                                  | 202  | 0      | 1568  |
    // | baseRoyalties      | struct RoyaltyInfo[]                         | 251  | 0      | 32    |
    // | tokenRoyalties     | mapping(uint256 => struct RoyaltyInfo[])     | 252  | 0      | 32    |
    // | currentId          | uint96                                       | 253  | 0      | 12    |
    // | configManager      | address                                      | 253  | 12     | 20    |
    // | metadataRenderer   | address                                      | 254  | 0      | 20    |
    // | issuerInfo         | struct IssuerInfo                            | 255  | 0      | 160   |
    // | _genArtInfo        | mapping(uint96 => struct TokenInfo)          | 260  | 0      | 32    |
    // |░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|
    // |-------------------------------------------------------------------------------------------|

    /// @dev Modifier for restricting calls to only authorized contracts
    modifier onlyContract(bytes32 _name) {
        if (msg.sender != IContractRegistry(contractRegistry).contracts(_name))
            revert UnauthorizedCaller();
        _;
    }

    /// @inheritdoc IFxGenArt721
    function initialize(
        address _owner,
        address _contractRegistry,
        address _roleRegistry,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external initializer {
        __ERC721_init("FxGenArt721", "FXHASH");
        __ERC721URIStorage_init();
        __Ownable_init();
        transferOwnership(_owner);
        _setBaseRoyalties(_royaltyReceivers, _basisPoints);
        contractRegistry = _contractRegistry;
        roleRegistry = _roleRegistry;
        issuerInfo.projectInfo = _projectInfo;
        issuerInfo.primaryReceiver = _primaryReceiver;
        for (uint256 i; i < _minters.length; ) {
            issuerInfo.minters[_minters[i]] = true;
            unchecked {
                ++i;
            }
        }

        emit ProjectInitialized(_projectInfo, _primaryReceiver, _minters);
    }

    /// @inheritdoc IFxGenArt721
    function setMetadata(address _metadata) external onlyOwner {
        metadata = _metadata;
    }

    /// @inheritdoc IFxGenArt721
    function genArtInfo(uint96 _tokenId) external view returns (TokenInfo memory) {
        return _genArtInfo[_tokenId];
    }

    /// @inheritdoc IFxGenArt721
    function isMinter(address _minter) public view returns (bool) {
        return issuerInfo.minters[_minter];
    }

    /// @inheritdoc ERC721URIStorageUpgradeable
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);

        if (bytes(_genArtInfo[uint96(_tokenId)].offChainPointer).length > 0) {
            return IFxMetadata(metadata).renderOffchain(_tokenId);
        } else {
            return IFxMetadata(metadata).renderOnchain(_tokenId);
        }
    }

    /// @inheritdoc ERC721URIStorageUpgradeable
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721URIStorageUpgradeable, RoyaltyManager) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    /// @inheritdoc ERC721Upgradeable
    function _exists(
        uint256 _tokenId
    ) internal view override(ERC721Upgradeable, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }
}
