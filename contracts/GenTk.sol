// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./royalties/RoyaltiesV2.sol";
import "./royalties/IERC2981.sol";
import "./royalties/impl/AbstractRoyalties.sol";
import "./GenTkProject.sol";
import "./IGenTk.sol";
import "./IGenTkProject.sol";

contract GenTk is ERC721URIStorage, AccessControl, RoyaltiesV2, IERC2981, IGenTk {
    using SafeMath for uint256;

    bytes32 public constant FXHASH_ADMIN = keccak256("FXHASH_ADMIN");

    // Override supportsInterface function
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl, IGenTk) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId
                || interfaceId == type(IGenTk).interfaceId
                || interfaceId == type(RoyaltiesV2).interfaceId
                || super.supportsInterface(interfaceId);
    }

    function getRaribleV2Royalties(uint256 id) override external view returns (LibPart.Part[] memory) {
        return genTkProject.getRaribleV2Royalties(tokenData[id].projectId);
    }

    /*
    *Token (ERC721, ERC721Minimal, ERC721MinimalMeta, ERC1155 ) can have a number of different royalties beneficiaries
    *calculate sum all royalties, but royalties beneficiary will be only one royalties[0].account, according to rules of IERC2981
    */
    function royaltyInfo(uint256 id, uint256 _salePrice) override external view returns (address receiver, uint256 royaltyAmount) {
        LibPart.Part[] memory tkRoyalties = genTkProject.getRaribleV2Royalties(tokenData[id].projectId);
        if (tkRoyalties.length == 0) {
            receiver = address(0);
            royaltyAmount = 0;
            return(receiver, royaltyAmount);
        }
        LibPart.Part[] memory _royalties = tkRoyalties;
        receiver = _royalties[0].account;
        uint percent;
        for (uint i = 0; i < _royalties.length; ++i) {
            percent += _royalties[i].value;
        }
        //don`t need require(percent < 10000, "Token royalty > 100%"); here, because check later in calculateRoyalties
        royaltyAmount = percent * _salePrice / 10000;
    }
    struct TokenData {
        uint256 projectId;
        uint256 iteration;
        bool metadataAssigned;
    }

    uint256 public tokenIdSeq;
    string private defaultURI = "";
    GenTkProject public genTkProject;

    mapping(uint256 => TokenData) public tokenData;

    constructor() ERC721("GenTk", "GTK") {
        genTkProject = GenTkProject(address(0));
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(FXHASH_ADMIN, _msgSender());
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "GenTk: Caller is not an admin");
        _;
    }

    modifier onlyFxHashAdmin() {
        require(hasRole(FXHASH_ADMIN, _msgSender()), "GenTk: Caller is not a FxHash admin");
        _;
    }

    modifier onlyGenTkProject() {
        require(msg.sender == address(genTkProject), "GenTk: Caller is not the GenTkProject");
        _;
    }

    function getDefaultURI() public view returns (string memory) {
        return defaultURI;
    }

    function setDefaultURI(string memory _defaultURI) public onlyFxHashAdmin {
        defaultURI = _defaultURI;
    }

    // Function to update token metadata by the owner
    function assignMetadata(uint256 tokenId, string memory newURI) public onlyFxHashAdmin {
        tokenData[tokenIdSeq].metadataAssigned = true;
        _setTokenURI(tokenId, newURI);
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        grantRole(FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        revokeRole(FXHASH_ADMIN, _admin);
    }

    // Function to set the genTkProjectContract address
    function setGenTkProject(GenTkProject newGenTkProject) public onlyFxHashAdmin {
        genTkProject = GenTkProject(newGenTkProject);
    }

    function getGenTkProject() override public view returns (GenTkProject) {
        return genTkProject;
    }

    // Batch minting method for GenTks, only callable by the genTkProjectContract contract
    function mintGenTks(address to, uint256 projectId, uint256 iteration) public onlyGenTkProject {
        _mint(to, tokenIdSeq);
        _setTokenURI(tokenIdSeq, defaultURI);
        TokenData memory tknData = TokenData({
            projectId: projectId,
            iteration: iteration,
            metadataAssigned: false
        });
        tokenData[tokenIdSeq] = tknData;
        tokenIdSeq.add(1);
    }
}
