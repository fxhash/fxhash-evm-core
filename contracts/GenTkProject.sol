// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

import "./royalties/RoyaltiesV2.sol";
import "./royalties/IERC2981.sol";
import "./royalties/impl/AbstractRoyalties.sol";
import "./GenTk.sol";
import "./IGenTk.sol";
import "./IGenTkProject.sol";

contract GenTkProject is ERC721URIStorage, AccessControl, RoyaltiesV2, AbstractRoyalties, IERC2981, IGenTkProject {
    using SafeMath for uint256;

    bytes32 public constant FXHASH_ADMIN = keccak256("FXHASH_ADMIN");

    // mapping to store project details
    mapping(uint256 => Project) public projects;

    uint256 public projectId;

    GenTk public genTk;

    // event to emit when a new project is added
    event ProjectCreated(uint256 indexed projectId, address indexed creator);

    constructor() ERC721("GenTkProject", "GTKP") {
        genTk = GenTk(address(0));
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

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        grantRole(FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        revokeRole(FXHASH_ADMIN, _admin);
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl, IGenTkProject) returns (bool) {
        return  interfaceId == type(IERC2981).interfaceId
                || interfaceId == type(RoyaltiesV2).interfaceId
                || interfaceId == type(IGenTkProject).interfaceId
                || super.supportsInterface(interfaceId);
    }

    function getRaribleV2Royalties(uint256 id) override public view returns (LibPart.Part[] memory) {
        return royalties[id];
    }

    function _onRoyaltiesSet(uint256 id, LibPart.Part[] memory _royalties) override internal {
        emit RoyaltiesSet(id, _royalties);
    }

    /*
    *Token (ERC721, ERC721Minimal, ERC721MinimalMeta, ERC1155 ) can have a number of different royalties beneficiaries
    *calculate sum all royalties, but royalties beneficiary will be only one royalties[0].account, according to rules of IERC2981
    */
    function royaltyInfo(uint256 id, uint256 _salePrice) override public view returns (address receiver, uint256 royaltyAmount) {
        if (royalties[id].length == 0) {
            receiver = address(0);
            royaltyAmount = 0;
            return(receiver, royaltyAmount);
        }
        LibPart.Part[] memory _royalties = royalties[id];
        receiver = _royalties[0].account;
        uint percent;
        for (uint i = 0; i < _royalties.length; ++i) {
            percent += _royalties[i].value;
        }
        //don`t need require(percent < 10000, "Token royalty > 100%"); here, because check later in calculateRoyalties
        royaltyAmount = percent * _salePrice / 10000;
    }


    // Getter for genTk
    function getGenTk() override public view returns (GenTk) {
        return genTk;
    }

    // Setter for genTk
    function setGenTk(GenTk _genTk) override public onlyFxHashAdmin {
        // Check that the contract implements the GenTk interface
        require(_genTk.supportsInterface(type(IGenTk).interfaceId), "Provided contract does not implement IGenTk");

        genTk = _genTk;
    }

    // Function to create a new project
    function createProject(
        uint256 editions,
        uint256 price,
        uint256 openingTime,
        uint256 royaltiesBPs,
        string calldata projectURI,
        LibPart.Part[] memory _royalties
    ) public {
        require(editions > 0, "Invalid edition number");
        require(price > 0, "Invalid edition price");
        require(openingTime > block.timestamp, "Invalid opening time");
        require(bytes(projectURI).length > 0, "Invalid project URI");
        require(royaltiesBPs < 10000, "Royalties can't exceed 100%");

        // create and store project
        Project memory newProject = Project({
            editions: editions,
            price: price,
            openingTime: openingTime,
            availableSupply: editions,
            royaltiesBPs: royaltiesBPs
        });

        projects[projectId] = newProject;
        _mint(msg.sender, projectId);
        _setTokenURI(projectId, projectURI);
        _saveRoyalties(projectId, _royalties);
        emit ProjectCreated(projectId, msg.sender);
        projectId = projectId.add(1);
    }

    function mint(uint256 genTkProjectId) public payable {
        Project memory project = projects[genTkProjectId];
        require(block.timestamp >= project.openingTime, "Sale has not started");
        require(project.availableSupply > 0, "No more tokens available for this project");
        require(msg.value == project.price, "Ether value sent is not correct");

        projects[genTkProjectId].availableSupply = projects[genTkProjectId].availableSupply.sub(1); // Decrease available tokens

        LibPart.Part[] memory royaltyConfig = royalties[genTkProjectId];
        uint256 totalRoyalties = msg.value * project.royaltiesBPs / 10000;
        uint256 projectOwnerShare = msg.value - totalRoyalties; // the remaining amount goes to the project owner
         // total royalties to distribute
        for (uint i = 0; i < royaltyConfig.length; i++) {
            uint256 recipientShare = totalRoyalties * royaltyConfig[i].value / 10000;
            Address.sendValue(royaltyConfig[i].account, recipientShare);
        }

        // Send the remaining amount to the project owner
        Address.sendValue(payable(ownerOf(genTkProjectId)), projectOwnerShare);

        genTk.mintGenTks(msg.sender, genTkProjectId, project.editions - project.availableSupply); // Call the mint function of GenTk contract
    }

}
