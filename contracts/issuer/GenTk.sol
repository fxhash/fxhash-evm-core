// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721Upgradeable, IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {RoyaltyManager} from "contracts/royalties/RoyaltyManager.sol";

import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import {IFactory} from "contracts/interfaces/IFactory.sol";
import {IGenTk, TokenParams} from "contracts/interfaces/IGenTk.sol";
import {IIssuer, IssuerData} from "contracts/interfaces/IIssuer.sol";
import {IOnChainTokenMetadataManager} from "contracts/interfaces/IOnChainTokenMetadataManager.sol";

contract GenTk is ERC721URIStorageUpgradeable, OwnableUpgradeable, RoyaltyManager, IGenTk {
    struct TokenMetadata {
        uint256 tokenId;
        string metadata;
    }

    struct OnChainTokenMetadata {
        uint256 tokenId;
        bytes metadata;
    }

    struct TokenData {
        uint256 iteration;
        bytes inputBytes;
        address minter;
        bool assigned;
    }

    IIssuer private issuer;
    IConfigurationManager private configManager;

    mapping(uint256 => TokenData) public tokenData;

    event TokenMinted(TokenParams _params);
    event TokenMetadataAssigned(TokenMetadata[] _params);
    event OnChainTokenMetadataAssigned(OnChainTokenMetadata[] _params);

    modifier onlySigner() {
        require(msg.sender == configManager.contracts("signer"), "Caller is not signer");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == address(issuer), "Caller is not issuer");
        _;
    }

    modifier onlyFxHashAdmin() {
        require(msg.sender == configManager.contracts("admin"), "Caller is not FXHASH admin");
        _;
    }

    function initialize(
        address payable[] calldata _receivers,
        uint96[] calldata _basisPoints,
        address _configManager,
        address _issuer,
        address _owner
    ) external initializer {
        _setBaseRoyalties(_receivers, _basisPoints);
        __ERC721_init("GenTk", "GTK");
        __ERC721URIStorage_init();
        __Ownable_init();
        issuer = IIssuer(_issuer);
        configManager = IConfigurationManager(_configManager);
        transferOwnership(_owner);
    }

    function mint(TokenParams calldata _params) external onlyIssuer {
        _mint(_params.receiver, _params.tokenId);
        _setTokenURI(_params.tokenId, _params.metadata);
        tokenData[_params.tokenId] = TokenData({
            iteration: _params.iteration,
            inputBytes: _params.inputBytes,
            minter: _params.receiver,
            assigned: false
        });
        emit TokenMinted(_params);
    }

    function assignOnChainMetadata(OnChainTokenMetadata[] calldata _params) external onlySigner {
        for (uint256 i = 0; i < _params.length; i++) {
            OnChainTokenMetadata memory _tokenData = _params[i];

            require(tokenData[_tokenData.tokenId].minter != address(0), "TOKEN_UNDEFINED");
            _setTokenURI(_tokenData.tokenId, string(_tokenData.metadata));
        }
        emit OnChainTokenMetadataAssigned(_params);
    }

    function assignMetadata(TokenMetadata[] calldata _params) external onlySigner {
        for (uint256 i = 0; i < _params.length; i++) {
            TokenMetadata memory _tokenData = _params[i];
            require(tokenData[_tokenData.tokenId].minter != address(0), "TOKEN_UNDEFINED");
            _setTokenURI(_tokenData.tokenId, _tokenData.metadata);
        }
        emit TokenMetadataAssigned(_params);
    }

    function setConfigManager(address _configManager) external onlyFxHashAdmin {
        configManager = IConfigurationManager(_configManager);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = super.tokenURI(tokenId);
        TokenData memory _tokenData = tokenData[tokenId];
        IssuerData memory issuerData = issuer.getIssuer();
        require(_tokenData.minter != address(0), "TOKEN_UNDEFINED");
        if (issuerData.onChainData.length > 0) {
            string memory onChainURI = IOnChainTokenMetadataManager(
                configManager.contracts("onChainMetaManager")
            ).getOnChainURI(bytes(_tokenURI), issuerData.onChainData);
            return onChainURI;
        } else {
            return _tokenURI;
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorageUpgradeable, RoyaltyManager) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IGenTk).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _exists(
        uint256 _tokenId
    ) internal view override(ERC721Upgradeable, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }
}
