// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC721, ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {IConfigurationManager} from "contracts/interfaces/IConfigurationManager.sol";
import {IERC2981} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {IERC721, IERC165} from "@openzeppelin/contracts/interfaces/IERC721.sol";
import {IGenTk} from "contracts/interfaces/IGenTk.sol";
import {IIssuer} from "contracts/interfaces/IIssuer.sol";
import {IOnChainTokenMetadataManager} from "contracts/interfaces/IOnChainTokenMetadataManager.sol";
import {LibIssuer} from "contracts/libs/LibIssuer.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract GenTk is ERC721URIStorage, Ownable, IERC2981, IGenTk {
    IIssuer private issuer;
    IConfigurationManager private configManager;
    mapping(uint256 => TokenData) public tokenData;

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

    constructor(address _owner, address _issuer, address _configManager) ERC721("GenTK", "GTK") {
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
    ) public view override(ERC721URIStorage, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
}
