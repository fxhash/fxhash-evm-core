// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721URIStorageUpgradeable, ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IConfigManager} from "contracts/interfaces/IConfigManager.sol";
import {IFxGenArt721, IssuerInfo, ProjectInfo, RoyaltyInfo, TokenInfo} from "contracts/interfaces/IFxGenArt721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {RoyaltyManager} from "contracts/royalties/RoyaltyManager.sol";

import "contracts/utils/Constants.sol";

contract FxGenArt721 is
    IFxGenArt721,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    RoyaltyManager
{
    address public config;
    uint96 public tokenId;
    IssuerInfo public issuerInfo;
    mapping(uint96 => TokenInfo) internal _genArtInfo;

    modifier onlyContract(bytes32 _name) {
        if (msg.sender != IConfigManager(config).contracts(_name)) revert UnauthorizedCaller();
        _;
    }

    function initialize(
        address _owner,
        address _config,
        ProjectInfo calldata _projectInfo,
        RoyaltyInfo calldata _primarySplits,
        address[] calldata _minters,
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints
    ) external {
        __ERC721_init("FxGenArt721", "FXHASH");
        __ERC721URIStorage_init();
        __Ownable_init();
        config = _config;
        issuerInfo.projectInfo = _projectInfo;
        issuerInfo.primarySplits = _primarySplits;
        for (uint256 i; i < _minters.length; ++i) {
            issuerInfo.minters[_minters[i]] = true;
        }
        _setBaseRoyalties(_receivers, _basisPoints);
        transferOwnership(_owner);

        emit ProjectInitialized(_projectInfo, _primarySplits, _minters, _receivers, _basisPoints);
    }

    function genArtInfo(uint96 _tokenId) external view returns (TokenInfo memory) {
        return _genArtInfo[_tokenId];
    }

    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721URIStorageUpgradeable, RoyaltyManager) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function _exists(
        uint256 _tokenId
    ) internal view override(ERC721Upgradeable, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }
}
