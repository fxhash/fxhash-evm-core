// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";
import "contracts/interfaces/IIssuerToken.sol";
import "contracts/interfaces/IGenTk.sol";

contract GenTk is
    ERC721URIStorageUpgradeable,
    IERC2981Upgradeable,
    FxHashAdminVerify,
    IGenTk
{
    struct TokenMetadata {
        uint256 tokenId;
        string metadata;
    }

    struct TokenData {
        uint256 issuerId;
        uint256 iteration;
        bytes inputBytes;
        address minter;
        bool assigned;
    }

    mapping(uint256 => TokenData) public tokenData;
    uint256 public allTokens;
    address public signer;
    address public treasury;
    IIssuerToken issuer;

    constructor(
        address _admin,
        address _signer,
        address _treasury,
        address _issuer
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(FXHASH_ADMIN, _admin);
        issuer = IIssuerToken(_issuer);
        signer = _signer;
        treasury = _treasury;
    }

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
        allTokens += 1;
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
    }

    function setSigner(address _signer) external onlyAdmin {
        signer = _signer;
    }

    function setTreasury(address _treasury) external onlyAdmin {
        treasury = _treasury;
    }

    function transferTreasury(uint256 _amount) external onlyAdmin {
        require(_amount <= address(this).balance, "INSUFFISCIENT_BALANCE");
        payable(treasury).transfer(_amount);
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(AccessControl, ERC721URIStorageUpgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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

    receive() external payable {}
}
