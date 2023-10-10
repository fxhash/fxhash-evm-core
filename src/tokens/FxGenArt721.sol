// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {IRandomizer} from "src/interfaces/IRandomizer.sol";
import {IRenderer} from "src/interfaces/IRenderer.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

import "src/utils/Constants.sol";

/**
 * @title FxGenArt721
 * @notice See the documentation in {IFxGenArt721}
 */
contract FxGenArt721 is IFxGenArt721, Initializable, ERC721, Ownable, Pausable, RoyaltyManager {
    /// @dev Project name
    string internal name_;
    /// @dev Project symbol
    string internal symbol_;
    /// @inheritdoc IFxGenArt721
    address public immutable roleRegistry;
    /// @inheritdoc IFxGenArt721
    uint96 public totalSupply;
    /// @inheritdoc IFxGenArt721
    address public randomizer;
    /// @inheritdoc IFxGenArt721
    address public renderer;
    /// @inheritdoc IFxGenArt721
    IssuerInfo public issuerInfo;
    /// @inheritdoc IFxGenArt721
    MetadataInfo public metadataInfo;
    /// @inheritdoc IFxGenArt721
    mapping(uint256 => GenArtInfo) public genArtInfo;

    /*//////////////////////////////////////////////////////////////////////////
                                  MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

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
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Sets core registry contracts
    constructor(address _roleRegistry) ERC721("FxGenArt721", "FXHASH") {
        roleRegistry = _roleRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZATION
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function initialize(
        address _owner,
        uint256 _lockTime,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external initializer {
        name_ = _initInfo.name;
        symbol_ = _initInfo.symbol;
        issuerInfo.primaryReceiver = _initInfo.primaryReceiver;
        issuerInfo.projectInfo = _projectInfo;
        metadataInfo = _metadataInfo;

        _transferOwnership(_owner);
        _emitTags(_initInfo.tagNames);
        _registerMinters(_lockTime, _mintInfo);
        _setRandomizer(_initInfo.randomizer);
        _setRenderer(_initInfo.renderer);
        _setBaseRoyalties(_royaltyReceivers, _basisPoints);

        emit ProjectInitialized(_initInfo.primaryReceiver, _projectInfo, _metadataInfo, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function mintRandom(address _to, uint256 _amount) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.enabled) revert MintInactive();
        for (uint256 i; i < _amount; ++i) {
            _mintRandom(_to, ++totalSupply);
        }
    }

    /// @inheritdoc IFxGenArt721
    function mintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.enabled) revert MintInactive();
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /// @inheritdoc ISeedConsumer
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external {
        if (msg.sender != randomizer) revert NotAuthorized();
        genArtInfo[_tokenId].seed = _seed;
        emit SeedFulfilled(randomizer, _tokenId, _seed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function ownerMintRandom(address _to) external onlyOwner whenNotPaused {
        _mintRandom(_to, ++totalSupply);
    }

    /// @inheritdoc IFxGenArt721
    function ownerMintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused {
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /// @inheritdoc IFxGenArt721
    function reduceSupply(uint120 _supply) external onlyOwner {
        if (_supply >= issuerInfo.projectInfo.supply || _supply < totalSupply) {
            revert InvalidAmount();
        }
        issuerInfo.projectInfo.supply = _supply;
    }

    /// @inheritdoc IFxGenArt721
    function toggleMint() external onlyOwner {
        issuerInfo.projectInfo.enabled = !issuerInfo.projectInfo.enabled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function setBaseURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        metadataInfo.baseURI = _uri;
        emit BaseURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setContractURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        issuerInfo.projectInfo.contractURI = _uri;
        emit ContractURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setImageURI(string calldata _uri) external onlyRole(ADMIN_ROLE) {
        metadataInfo.imageURI = _uri;
        emit ImageURIUpdated(_uri);
    }

    /// @inheritdoc IFxGenArt721
    function setRandomizer(address _randomizer) external onlyRole(ADMIN_ROLE) {
        _setRandomizer(_randomizer);
    }

    /// @inheritdoc IFxGenArt721
    function setRenderer(address _renderer) external onlyRole(ADMIN_ROLE) {
        _setRenderer(_renderer);
    }

    /// @inheritdoc IFxGenArt721
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @inheritdoc IFxGenArt721
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                MODERATOR FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFxGenArt721
    function emitTags(string[] calldata _names) external onlyRole(TOKEN_MODERATOR_ROLE) {
        _emitTags(_names);
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
    function name() public view override returns (string memory) {
        return name_;
    }

    /// @inheritdoc ERC721
    function symbol() public view override returns (string memory) {
        return symbol_;
    }

    /// @inheritdoc ERC721
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        bytes memory data = abi.encode(issuerInfo.projectInfo, metadataInfo, genArtInfo[_tokenId]);
        return IRenderer(renderer).tokenURI(_tokenId, data);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints a single token to given account and generates random seed
     */
    function _mintRandom(address _to, uint256 _tokenId) internal {
        _mint(_to, _tokenId);
        IRandomizer(randomizer).requestRandomness(_tokenId);
    }

    /**
     * @dev Mints a single fxParams token to given account
     */
    function _mintParams(address _to, uint256 _tokenId, bytes calldata _fxParams) internal {
        if (issuerInfo.projectInfo.inputSize < _fxParams.length) revert InvalidInputSize();
        _mint(_to, _tokenId);
        genArtInfo[_tokenId].fxParams = _fxParams;
    }

    /**
     * @dev Registers arbitrary number of minter contracts
     * @param _mintInfo List of minter contracts and their reserves
     */
    function _registerMinters(uint256 _lockTime, MintInfo[] calldata _mintInfo) internal {
        address minter;
        uint128 totalAllocation;
        ReserveInfo memory reserveInfo;
        uint256 lockTime = _isVerified(owner()) ? 0 : _lockTime;
        unchecked {
            for (uint256 i; i < _mintInfo.length; ++i) {
                minter = _mintInfo[i].minter;
                reserveInfo = _mintInfo[i].reserveInfo;
                if (reserveInfo.startTime < block.timestamp + lockTime) {
                    revert InvalidStartTime();
                }
                if (reserveInfo.endTime < reserveInfo.startTime) {
                    revert InvalidEndTime();
                }
                if (!IAccessControl(roleRegistry).hasRole(MINTER_ROLE, minter)) {
                    revert UnauthorizedMinter();
                }
                IMinter(minter).setMintDetails(reserveInfo, _mintInfo[i].params);

                issuerInfo.minters[minter] = true;
                totalAllocation += reserveInfo.allocation;
            }
        }

        uint256 maxSupply = issuerInfo.projectInfo.supply;
        if (maxSupply != OPEN_EDITION_SUPPLY) {
            if (totalAllocation > maxSupply - totalSupply) revert AllocationExceeded();
        }
    }

    /// @dev Emits event for setting the tag names for a project
    function _emitTags(string[] calldata _names) internal {
        emit ProjectTags(_names);
    }

    /// @dev Sets the Randomizer contract
    function _setRandomizer(address _randomizer) internal {
        randomizer = _randomizer;
        emit RandomizerUpdated(_randomizer);
    }

    /// @dev Sets the Renderer contract
    function _setRenderer(address _renderer) internal {
        renderer = _renderer;
        emit RendererUpdated(_renderer);
    }

    /**
     * @dev Checks if user is verified on system
     */
    function _isVerified(address _user) internal view returns (bool) {
        return (IAccessControl(roleRegistry).hasRole(VERIFIED_USER_ROLE, _user));
    }

    /// @inheritdoc ERC721
    function _exists(uint256 _tokenId) internal view override(ERC721, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }
}
