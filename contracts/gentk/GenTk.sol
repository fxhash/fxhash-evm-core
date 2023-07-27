// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {IERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";
import {IERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC721Upgradeable.sol";
import {IERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import {IFactory} from "contracts/interfaces/IFactory.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IOnChainTokenMetadataManager} from "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import {LibIssuer} from "contracts/libs/LibIssuer.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract GenTk is ERC721URIStorageUpgradeable, OwnableUpgradeable, IERC2981Upgradeable, IGenTk {
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

    function initialize(
        address _configManager,
        address _issuer,
        address _owner
    ) external initializer {
        __ERC721_init("GenTk", "GTK");
        __ERC721URIStorage_init();
        __Ownable_init();
        issuer = IIssuer(_issuer);
        configManager = IConfigurationManager(_configManager);
        transferOwnership(_owner);
    }

    modifier onlySigner() {
        require(msg.sender == configManager.getAddress("signer"), "Caller is not signer");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == address(issuer), "Caller is not issuer");
        _;
    }

    modifier onlyFxHashAdmin() {
        require(msg.sender == configManager.getAddress("admin"), "Caller is not FXHASH admin");
        _;
    }

    /// @notice The issuer calls this entrypoint to issue a NFT within the
    /// project. This function is agnostic of any checks, which are happening at
    /// the Issuer level; it simply registers a new NFT in the contract.
    /// @param _params mint parameters
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

    /// @notice TO REMOVE most likely, see TODO.md
    function assignOnChainMetadata(OnChainTokenMetadata[] calldata _params) external onlySigner {
        for (uint256 i = 0; i < _params.length; i++) {
            OnChainTokenMetadata memory _tokenData = _params[i];

            require(tokenData[_tokenData.tokenId].minter != address(0), "TOKEN_UNDEFINED");
            _setTokenURI(_tokenData.tokenId, string(_tokenData.metadata));
        }
        emit OnChainTokenMetadataAssigned(_params);
    }

    /// @notice The signer generates the metadata of every NFT off-chain (takes
    /// a capture, extract features, etc...) and injects the generated metadata
    /// on chain through this function. 
    /// @param _params an array of the token metadata to be revealed
    function assignMetadata(TokenMetadata[] calldata _params) external onlySigner {
        // for every reveal, saves the associated metadata 
        for (uint256 i = 0; i < _params.length; i++) {
            TokenMetadata memory _tokenData = _params[i];
            require(tokenData[_tokenData.tokenId].minter != address(0), "TOKEN_UNDEFINED");
            _setTokenURI(_tokenData.tokenId, _tokenData.metadata);
        }
        emit TokenMetadataAssigned(_params);
    }

    /// @notice Get the royalty info associated with a NFT
    /// @param tokenId the ID of the token
    /// @param salePrice price of the sale for which royalty info is requested
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        return issuer.royaltyInfo(tokenId, salePrice);
    }

    /// @notice Get the URI of a token, where the metadata is either constructed i
    /// on-the-fly if on-chain, or where a pointer to the metadata is simply
    /// returned if off-chain
    /// @param tokenId token ID to fetch
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = super.tokenURI(tokenId);
        TokenData memory _tokenData = tokenData[tokenId];
        // get the issuer associated to this NFT contract
        LibIssuer.IssuerData memory issuerData = issuer.getIssuer();
        require(_tokenData.minter != address(0), "TOKEN_UNDEFINED");
        // if the metadata is stored on-chain
        if (issuerData.onChainData.length > 0) {
            string memory onChainURI = IOnChainTokenMetadataManager(
                configManager.getAddress("onChainMetaManager")
            ).getOnChainURI(bytes(_tokenURI), issuerData.onChainData);
            return onChainURI;
        } 
        // if the metadata is stored off-chain
        else {
            return _tokenURI;
        }
    }

    function setConfigManager(address _configManager) external onlyFxHashAdmin {
        configManager = IConfigurationManager(_configManager);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorageUpgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IGenTk).interfaceId ||
            interfaceId == type(IERC2981Upgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
