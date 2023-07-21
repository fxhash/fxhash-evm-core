// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/IGenTk.sol";
import "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import "contracts/interfaces/IConfigurationManager.sol";

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "contracts/libs/LibIssuer.sol";

contract GenTk is ERC721URIStorageUpgradeable, OwnableUpgradeable, IERC2981, IGenTk {
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

    constructor() ERC721Upgradeable() {}

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

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        return issuer.royaltyInfo(tokenId, salePrice);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = super.tokenURI(tokenId);
        TokenData memory _tokenData = tokenData[tokenId];
        LibIssuer.IssuerData memory issuerData = issuer.getIssuer();
        require(_tokenData.minter != address(0), "TOKEN_UNDEFINED");
        if (issuerData.onChainData.length > 0) {
            string memory onChainURI = IOnChainTokenMetadataManager(
                configManager.getAddress("onChainMetaManager")
            ).getOnChainURI(bytes(_tokenURI), issuerData.onChainData);
            return onChainURI;
        } else {
            return _tokenURI;
        }
    }

    function setConfigManager(address _configManager) external onlyFxHashAdmin {
        configManager = IConfigurationManager(_configManager);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorageUpgradeable, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IGenTk).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
