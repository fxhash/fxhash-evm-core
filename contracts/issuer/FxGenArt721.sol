// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721URIStorageUpgradeable, ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IConfigManager} from "contracts/interfaces/IConfigManager.sol";
import {IFxGenArt721, IssuerInfo, PaymentInfo, ProjectInfo, MetadataInfo, TokenInfo} from "contracts/interfaces/IFxGenArt721.sol";
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
    address public configManager;
    /// @dev Internal struct of IssuerInfo
    IssuerInfo public issuerInfo;
    /// @dev Internal mapping of token ID to TokenInfo
    mapping(uint96 => TokenInfo) internal _genArtInfo;

    /// @dev Modifier for authorizing calls based on the given contract
    modifier onlyContract(bytes32 _name) {
        if (msg.sender != IConfigManager(configManager).contracts(_name))
            revert UnauthorizedCaller();
        _;
    }

    /// @inheritdoc IFxGenArt721
    function initialize(
        address _owner,
        address _configManager,
        ProjectInfo calldata _projectInfo,
        PaymentInfo calldata _primarySplit,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external {
        __ERC721_init("FxGenArt721", "FXHASH");
        __ERC721URIStorage_init();
        __Ownable_init();
        configManager = _configManager;
        issuerInfo.projectInfo = _projectInfo;
        issuerInfo.primarySplit = _primarySplit;
        for (uint256 i; i < _minters.length; ++i) issuerInfo.minters[_minters[i]] = true;
        _setBaseRoyalties(_receivers, _basisPoints);
        transferOwnership(_owner);

        emit ProjectInitialized(_projectInfo, _primarySplit, _minters);
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
