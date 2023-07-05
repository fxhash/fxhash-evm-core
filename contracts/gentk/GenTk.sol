// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "contracts/interfaces/IIssuer.sol";
import "contracts/interfaces/IGenTk.sol";
import "contracts/interfaces/IOnChainTokenMetadataManager.sol";

import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "contracts/abstract/admin/AuthorizedCaller.sol";
import "contracts/libs/LibIssuer.sol";

import "hardhat/console.sol";

contract GenTk is ERC721URIStorage, AuthorizedCaller, IERC2981, IGenTk {
    struct TokenMetadata {
        uint256 tokenId;
        string metadata;
    }

    struct OnChainTokenMetadata {
        uint256 tokenId;
        uint256 issuerId;
        bytes metadata;
    }

    struct TokenData {
        uint256 issuerId;
        uint256 iteration;
        bytes inputBytes;
        address minter;
        bool assigned;
    }

    address private signer;
    address private treasury;
    IIssuer private issuer;
    IOnChainTokenMetadataManager private onChainTokenMetadataManager;
    mapping(uint256 => TokenData) private tokenData;

    event TokenMinted(TokenParams _params);
    event TokenMetadataAssigned(TokenMetadata[] _params);
    event OnChainTokenMetadataAssigned(OnChainTokenMetadata[] _params);

    constructor(
        address _admin,
        address _signer,
        address _treasury,
        address _issuer,
        address _onChainTokenMetadataManager
    ) ERC721("GenTK", "GTK") {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(AUTHORIZED_CALLER, _admin);
        issuer = IIssuer(_issuer);
        signer = _signer;
        treasury = _treasury;
        onChainTokenMetadataManager = IOnChainTokenMetadataManager(
            _onChainTokenMetadataManager
        );
    }

    receive() external payable {}

    modifier onlySigner() {
        require(_msgSender() == signer, "Caller is not signer");
        _;
    }

    modifier onlyFxHashIssuer() {
        require(_msgSender() == address(issuer), "Caller is not issuer");
        _;
    }

    function mint(TokenParams calldata _params) external onlyFxHashIssuer {
        _mint(_params.receiver, _params.tokenId);
        _setTokenURI(_params.tokenId, _params.metadata);
        tokenData[_params.tokenId] = TokenData({
            issuerId: _params.issuerId,
            iteration: _params.iteration,
            inputBytes: _params.inputBytes,
            minter: _params.receiver,
            assigned: false
        });
        emit TokenMinted(_params);
    }

    function assignOnChainMetadata(
        OnChainTokenMetadata[] calldata _params
    ) external onlySigner {
        for (uint256 i = 0; i < _params.length; i++) {
            OnChainTokenMetadata memory _tokenData = _params[i];

            require(
                tokenData[_tokenData.tokenId].minter != address(0),
                "TOKEN_UNDEFINED"
            );
            _setTokenURI(_tokenData.tokenId, string(_tokenData.metadata));
        }
        emit OnChainTokenMetadataAssigned(_params);
    }

    function assignMetadata(
        TokenMetadata[] calldata _params
    ) external onlySigner {
        for (uint256 i = 0; i < _params.length; i++) {
            TokenMetadata memory _tokenData = _params[i];
            require(
                tokenData[_tokenData.tokenId].minter != address(0),
                "TOKEN_UNDEFINED"
            );
            _setTokenURI(_tokenData.tokenId, _tokenData.metadata);
        }
        emit TokenMetadataAssigned(_params);
    }

    function transferTreasury(uint256 _amount) external onlyAdmin {
        require(_amount <= address(this).balance, "INSUFFISCIENT_BALANCE");
        payable(treasury).transfer(_amount);
    }

    function setSigner(address _signer) external onlyAdmin {
        signer = _signer;
    }

    function setTreasury(address _treasury) external onlyAdmin {
        treasury = _treasury;
    }

    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        return issuer.royaltyInfo(tokenId, salePrice);
    }

    function getTokenData(
        uint256 _tokenId
    ) external view returns (TokenData memory) {
        return tokenData[_tokenId];
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = super.tokenURI(tokenId);
        TokenData memory _tokenData = tokenData[tokenId];
        LibIssuer.IssuerData memory issuerData = issuer.getIssuer();
        require(_tokenData.minter != address(0), "TOKEN_UNDEFINED");
        if (issuerData.onChainData.length > 0) {
            string memory onChainURI = onChainTokenMetadataManager
                .getOnChainURI(bytes(_tokenURI), issuerData.onChainData);
            return onChainURI;
        } else {
            return _tokenURI;
        }
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(AccessControl, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IGenTk).interfaceId ||
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }
}
