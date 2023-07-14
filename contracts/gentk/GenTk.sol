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
    string private constant ADMIN = "admin";
    string private constant SIGNER = "signer";
    string private constant ONCHAIN_META_MANAGER = "onChainMetaManager";
    IIssuer private issuer;
    IConfigurationManager private configManager;
    mapping(uint256 => TokenData) public tokenData;

    modifier onlyFxHashAdmin() {
        if (msg.sender != configManager.getAddress(ADMIN)) revert NotFxHashAdmin();
        _;
    }

    modifier onlySigner() {
        if (msg.sender != configManager.getAddress(SIGNER)) revert NotSigner();
        _;
    }

    modifier onlyIssuer() {
        if (msg.sender != address(issuer)) revert NotIssuer();
        _;
    }

    constructor(address _owner, address _issuer, address _configManager) ERC721("GenTK", "GTK") {
        issuer = IIssuer(_issuer);
        configManager = IConfigurationManager(_configManager);
        transferOwnership(_owner);
    }

    function mint(TokenParams calldata _params) external onlyIssuer {
        address receiver = _params.receiver;
        uint256 tokenId = _params.tokenId;

        _mint(receiver, tokenId);
        _setTokenURI(tokenId, _params.metadata);

        tokenData[tokenId] = TokenData({
            iteration: _params.iteration,
            inputBytes: _params.inputBytes,
            minter: receiver,
            assigned: false
        });

        emit TokenMinted(_params);
    }

    function assignMetadata(TokenMetadata[] calldata _metadata) external onlySigner {
        uint256 tokenId;
        uint256 length = _metadata.length;
        for (uint256 i; i < length; ++i) {
            TokenMetadata memory _tokenData = _metadata[i];
            tokenId = _tokenData.tokenId;
            if (tokenData[tokenId].minter == address(0)) revert TokenUndefined();
            _setTokenURI(tokenId, _tokenData.metadata);
        }

        emit TokenMetadataAssigned(_metadata);
    }

    function assignOnChainMetadata(OnChainTokenMetadata[] calldata _params) external onlySigner {
        uint256 tokenId;
        uint256 length = _params.length;
        for (uint256 i; i < length; ++i) {
            OnChainTokenMetadata memory _tokenData = _params[i];
            tokenId = _tokenData.tokenId;
            if (tokenData[tokenId].minter == address(0)) revert TokenUndefined();
            _setTokenURI(tokenId, string(_tokenData.metadata));
        }

        emit OnChainTokenMetadataAssigned(_params);
    }

    function setConfigManager(address _configManager) external onlyFxHashAdmin {
        configManager = IConfigurationManager(_configManager);
    }

    function royaltyInfo(
        uint256 _tokenId,
        uint256 _salePrice
    ) external view override returns (address, uint256) {
        return issuer.royaltyInfo(_tokenId, _salePrice);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        LibIssuer.IssuerData memory issuerData = issuer.getIssuer();
        if (tokenData[_tokenId].minter == address(0)) revert TokenUndefined();

        if (issuerData.onChainData.length > 0) {
            string memory onChainURI = IOnChainTokenMetadataManager(
                configManager.getAddress(ONCHAIN_META_MANAGER)
            ).getOnChainURI(bytes(super.tokenURI(_tokenId)), issuerData.onChainData);
            return onChainURI;
        } else {
            return super.tokenURI(_tokenId);
        }
    }

    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721URIStorage, IERC165) returns (bool) {
        return _interfaceId == type(IERC2981).interfaceId || super.supportsInterface(_interfaceId);
    }
}
