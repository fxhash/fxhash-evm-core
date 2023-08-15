// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Base64} from "openzeppelin/contracts/utils/Base64.sol";
import {
    ERC721URIStorageUpgradeable,
    ERC721Upgradeable
} from "openzeppelin-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {
    IFxGenArt721,
    HTMLRequest,
    IssuerInfo,
    GenArtInfo,
    ProjectInfo,
    MintInfo,
    ReserveInfo
} from "src/interfaces/IFxGenArt721.sol";
import {IFxTokenRenderer} from "src/interfaces/IFxTokenRenderer.sol";
import {FxRoleRegistry} from "src/registries/FxRoleRegistry.sol";
import {FxRoyaltyManager} from "src/FxRoyaltyManager.sol";
import {OwnableUpgradeable} from "openzeppelin-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";

import "src/utils/Constants.sol";

/**
 * @title FxGenArt721
 * @notice See the documentation in {IFxGenArt721}
 */
contract FxGenArt721 is
    IFxGenArt721,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    FxRoyaltyManager
{
    using Strings for uint256;
    /// @inheritdoc IFxGenArt721

    address public immutable contractRegistry;
    /// @inheritdoc IFxGenArt721
    address public immutable roleRegistry;
    /// @inheritdoc IFxGenArt721
    uint96 public totalSupply;
    /// @inheritdoc IFxGenArt721
    address public renderer;
    /// @inheritdoc IFxGenArt721
    IssuerInfo public issuerInfo;
    /// @inheritdoc IFxGenArt721
    mapping(uint96 => GenArtInfo) public genArtInfo;

    // |-------------------------------------------------------------------------------------------|
    // |░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  STORAGE LAYOUT  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|
    // |--------------------|----------------------------------------------|------|--------|-------|
    // | Name               | Type                                         | Slot | Offset | Bytes |
    // |--------------------|----------------------------------------------|------|--------|-------|
    // | _initialized       | uint8                                        | 0    | 0      | 1     |
    // | _initializing      | bool                                         | 0    | 1      | 1     |
    // | __gap              | uint256[50]                                  | 1    | 0      | 1600  |
    // | __gap              | uint256[50]                                  | 51   | 0      | 1600  |
    // | _name              | string                                       | 101  | 0      | 32    |
    // | _symbol            | string                                       | 102  | 0      | 32    |
    // | _owners            | mapping(uint256 => address)                  | 103  | 0      | 32    |
    // | _balances          | mapping(address => uint256)                  | 104  | 0      | 32    |
    // | _tokenApprovals    | mapping(uint256 => address)                  | 105  | 0      | 32    |
    // | _operatorApprovals | mapping(address => mapping(address => bool)) | 106  | 0      | 32    |
    // | __gap              | uint256[44]                                  | 107  | 0      | 1408  |
    // | _tokenURIs         | mapping(uint256 => string)                   | 151  | 0      | 32    |
    // | __gap              | uint256[49]                                  | 152  | 0      | 1568  |
    // | _owner             | address                                      | 201  | 0      | 20    |
    // | __gap              | uint256[49]                                  | 202  | 0      | 1568  |
    // | baseRoyalties      | struct RoyaltyInfo[]                         | 251  | 0      | 32    |
    // | tokenRoyalties     | mapping(uint256 => struct RoyaltyInfo[])     | 252  | 0      | 32    |
    // | totalSupply        | uint96                                       | 253  | 0      | 12    |
    // | renderer           | address                                      | 253  | 12     | 20    |
    // | issuerInfo         | struct IssuerInfo                            | 254  | 0      | 160   |
    // | genArtInfo         | mapping(uint96 => struct GenArtInfo)         | 259  | 0      | 32    |
    // |░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░|
    // |-------------------------------------------------------------------------------------------|

    /// @dev Modifier for restricting calls to only registered contracts
    modifier onlyContract(bytes32 _name) {
        if (msg.sender != IFxContractRegistry(contractRegistry).contracts(_name)) {
            revert UnauthorizedContract();
        }
        _;
    }

    /// @dev Modifier for restricting calls to only registered minters
    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    /// @dev Initializes registry contracts
    constructor(address _contractRegistry, address _roleRegistry) {
        contractRegistry = _contractRegistry;
        roleRegistry = _roleRegistry;
    }

    /// @inheritdoc IFxGenArt721
    function initialize(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external initializer {
        __ERC721_init("FxGenArt721", "FXHASH");
        __ERC721URIStorage_init();
        __Ownable_init();
        transferOwnership(_owner);

        issuerInfo.projectInfo = _projectInfo;
        issuerInfo.primaryReceiver = _primaryReceiver;
        _registerMinters(_mintInfo);
        _setBaseRoyalties(_royaltyReceivers, _basisPoints);

        emit ProjectInitialized(_projectInfo, _mintInfo, _primaryReceiver);
    }

    /// @inheritdoc IFxGenArt721
    function ownerMint(address _to) external onlyOwner {
        if (issuerInfo.projectInfo.enabled) revert MintActive();
        _mint(_to, ++totalSupply);
    }

    /// @inheritdoc IFxGenArt721
    function publicMint(address _to, uint256 _amount) external onlyMinter {
        if (!issuerInfo.projectInfo.enabled) revert MintInactive();
        for (uint256 i; i < _amount;) {
            _mint(_to, ++totalSupply);
            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IFxGenArt721
    function setRenderer(address _renderer) external onlyOwner {
        renderer = _renderer;
    }

    /// @inheritdoc IFxGenArt721
    function toggleMint() external onlyOwner {
        issuerInfo.projectInfo.enabled = !issuerInfo.projectInfo.enabled;
    }

    /// @inheritdoc IFxGenArt721
    function contractURI() public view returns (string memory) {
        return issuerInfo.projectInfo.contractURI;
    }

    /// @inheritdoc IFxGenArt721
    function isMinter(address _minter) public view returns (bool) {
        return issuerInfo.minters[_minter];
    }

    /// @inheritdoc ERC721URIStorageUpgradeable
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        if (issuerInfo.projectInfo.codexId != SCRIPTY) {
            string memory baseURI = issuerInfo.projectInfo.metadataInfo.baseURI;
            return string.concat(baseURI, _tokenId.toString());
        } else {
            bytes32 seed = genArtInfo[uint96(_tokenId)].seed;
            bytes memory fxParams = genArtInfo[uint96(_tokenId)].fxParams;
            HTMLRequest memory animationURL = issuerInfo.projectInfo.metadataInfo.animation;
            HTMLRequest memory attributes = issuerInfo.projectInfo.metadataInfo.attributes;
            bytes memory onchainData = IFxTokenRenderer(renderer).renderOnchain(
                _tokenId, seed, fxParams, animationURL, attributes
            );

            return string(
                abi.encodePacked("data:application/json;base64,", Base64.encode(onchainData))
            );
        }
    }

    /// @inheritdoc ERC721URIStorageUpgradeable
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721URIStorageUpgradeable, FxRoyaltyManager)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    /// @dev Registers arbitrary number of minter contracts
    /// @param _mintInfo List minter contracts and their reserves
    function _registerMinters(MintInfo[] calldata _mintInfo) internal {
        address minter;
        uint128 totalAllocation;
        ReserveInfo memory reserveInfo;
        for (uint256 i; i < _mintInfo.length; ++i) {
            minter = _mintInfo[i].minter;
            reserveInfo = _mintInfo[i].reserveInfo;
            if (!FxRoleRegistry(roleRegistry).hasRole(MINTER_ROLE, minter)) {
                revert UnauthorizedMinter();
            }
            if (reserveInfo.startTime >= reserveInfo.endTime) revert InvalidReserveTime();
            issuerInfo.minters[minter] = true;
            totalAllocation += reserveInfo.allocation;
        }

        if (totalAllocation > issuerInfo.projectInfo.supply) revert AllocationExceeded();
    }

    /// @inheritdoc ERC721Upgradeable
    function _exists(uint256 _tokenId)
        internal
        view
        override(ERC721Upgradeable, FxRoyaltyManager)
        returns (bool)
    {
        return super._exists(_tokenId);
    }
}
