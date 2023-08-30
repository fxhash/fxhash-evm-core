// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {
    IFxGenArt721,
    GenArtInfo,
    IssuerInfo,
    MintInfo,
    ProjectInfo,
    ReserveInfo
} from "src/interfaces/IFxGenArt721.sol";
import {IFxTokenRenderer} from "src/interfaces/IFxTokenRenderer.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {FxRoyaltyManager} from "src/FxRoyaltyManager.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";

import "src/utils/Constants.sol" as CONSTANTS;

/**
 * @title FxGenArt721
 * @notice See the documentation in {IFxGenArt721}
 */
contract FxGenArt721 is IFxGenArt721, Initializable, Ownable, ERC721, FxRoyaltyManager {
    /// @inheritdoc IFxGenArt721
    address public immutable CONTRACT_REGISTRY;
    /// @inheritdoc IFxGenArt721
    address public immutable ROLE_REGISTRY;
    /// @inheritdoc IFxGenArt721
    uint96 public totalSupply;
    /// @inheritdoc IFxGenArt721
    address public renderer;
    /// @inheritdoc IFxGenArt721
    IssuerInfo public issuerInfo;
    /// @inheritdoc IFxGenArt721
    mapping(uint256 => GenArtInfo) public genArtInfo;

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Modifier for restricting calls to only registered contracts
     */
    modifier onlyContract(bytes32 _name) {
        if (msg.sender != IFxContractRegistry(CONTRACT_REGISTRY).contracts(_name)) {
            revert UnauthorizedContract();
        }
        _;
    }

    /**
     * @dev Modifier for restricting calls to only registered minters
     */
    modifier onlyMinter() {
        if (!isMinter(msg.sender)) revert UnregisteredMinter();
        _;
    }

    /**
     * @dev Modifier for restricting calls to only authorized accounts with given roles
     */
    modifier onlyRole(bytes32 _role) {
        if (!IAccessControl(ROLE_REGISTRY).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sets core registry contracts
    constructor(address _contractRegistry, address _roleRegistry) ERC721("FxGenArt721", "FXHASH") {
        CONTRACT_REGISTRY = _contractRegistry;
        ROLE_REGISTRY = _roleRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATION
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function initialize(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external initializer {
        _registerMinters(_mintInfo);
        _setBaseRoyalties(_royaltyReceivers, _basisPoints);
        _transferOwnership(_owner);

        issuerInfo.projectInfo = _projectInfo;
        issuerInfo.primaryReceiver = _primaryReceiver;

        emit ProjectInitialized(_primaryReceiver, _projectInfo, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function mint(address _to, uint256 _amount) external onlyMinter {
        if (!issuerInfo.projectInfo.enabled) revert MintInactive();
        unchecked {
            for (uint256 i; i < _amount; ++i) {
                _mint(_to, ++totalSupply);
            }
        }
    }

    /// @inheritdoc IFxGenArt721
    function burn(uint256 _tokenId) external {
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function ownerMint(address _to) external onlyOwner {
        _mint(_to, ++totalSupply);
    }

    /// @inheritdoc IFxGenArt721
    function reduceSupply(uint240 _supply) external onlyOwner {
        if (_supply >= issuerInfo.projectInfo.supply || _supply < totalSupply) {
            revert InvalidSupply();
        }
        issuerInfo.projectInfo.supply = _supply;
    }

    /// @inheritdoc IFxGenArt721
    function toggleMint() external onlyOwner {
        issuerInfo.projectInfo.enabled = !issuerInfo.projectInfo.enabled;
    }

    /// @inheritdoc IFxGenArt721
    function toggleOnchain() external onlyOwner {
        issuerInfo.projectInfo.onchain = !issuerInfo.projectInfo.onchain;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function setBaseURI(string calldata _uri) external onlyRole(CONSTANTS.ADMIN_ROLE) {
        issuerInfo.projectInfo.metadataInfo.baseURI = _uri;
        emit BaseURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setContractURI(string calldata _uri) external onlyRole(CONSTANTS.ADMIN_ROLE) {
        issuerInfo.projectInfo.contractURI = _uri;
        emit ContractURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setImageURI(string calldata _uri) external onlyRole(CONSTANTS.ADMIN_ROLE) {
        issuerInfo.projectInfo.metadataInfo.imageURI = _uri;
        emit ImageURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setRenderer(address _renderer) external onlyRole(CONSTANTS.ADMIN_ROLE) {
        renderer = _renderer;
        emit RendererUpdated(_renderer);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function contractURI() external view returns (string memory) {
        return issuerInfo.projectInfo.contractURI;
    }

    /// @inheritdoc IFxGenArt721
    function remainingSupply() external view returns (uint256) {
        return issuerInfo.projectInfo.supply - totalSupply;
    }

    /// @inheritdoc IFxGenArt721
    function isMinter(address _minter) public view returns (bool) {
        return issuerInfo.minters[_minter];
    }

    /// @inheritdoc ERC721
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, FxRoyaltyManager)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        _requireMinted(_tokenId);

        return IFxTokenRenderer(renderer).tokenURI(
            _tokenId, issuerInfo.projectInfo, genArtInfo[_tokenId]
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Registers arbitrary number of minter contracts
     * @param _mintInfo List of minter contracts and their reserves
     */
    function _registerMinters(MintInfo[] calldata _mintInfo) internal {
        address minter;
        uint128 totalAllocation;
        ReserveInfo memory reserveInfo;
        unchecked {
            for (uint256 i; i < _mintInfo.length; ++i) {
                minter = _mintInfo[i].minter;
                reserveInfo = _mintInfo[i].reserveInfo;
                if (!IAccessControl(ROLE_REGISTRY).hasRole(CONSTANTS.MINTER_ROLE, minter)) {
                    revert UnauthorizedMinter();
                }
                if (reserveInfo.startTime >= reserveInfo.endTime) revert InvalidReserveTime();
                issuerInfo.minters[minter] = true;
                totalAllocation += reserveInfo.allocation;
            }
        }

        if (totalAllocation > issuerInfo.projectInfo.supply) revert AllocationExceeded();
    }

    /// @inheritdoc ERC721
    function _exists(uint256 _tokenId)
        internal
        view
        override(ERC721, FxRoyaltyManager)
        returns (bool)
    {
        return super._exists(_tokenId);
    }
}
