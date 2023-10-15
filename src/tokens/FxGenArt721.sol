// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ECDSA} from "openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";

import {IAccessControl} from "openzeppelin/contracts/access/IAccessControl.sol";
import {IERC4906} from "openzeppelin/contracts/interfaces/IERC4906.sol";
import {IFxContractRegistry} from "src/interfaces/IFxContractRegistry.sol";
import {IFxGenArt721, GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/interfaces/IFxGenArt721.sol";
import {IMinter} from "src/interfaces/IMinter.sol";
import {IRandomizer} from "src/interfaces/IRandomizer.sol";
import {IRenderer} from "src/interfaces/IRenderer.sol";

import "src/utils/Constants.sol";

/**
 * @title FxGenArt721
 * @author fx(hash)
 * @notice See the documentation in {IFxGenArt721}
 */
contract FxGenArt721 is IFxGenArt721, IERC4906, ERC721, EIP712, Initializable, Ownable, Pausable, RoyaltyManager {
    /*//////////////////////////////////////////////////////////////////////////
                                    STORAGE
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    address public immutable contractRegistry;

    /**
     * @inheritdoc IFxGenArt721
     */
    address public immutable roleRegistry;

    /**
     * @dev Project name
     */
    string internal name_;

    /**
     * @dev Project symbol
     */
    string internal symbol_;

    /**
     * @inheritdoc IFxGenArt721
     */
    uint96 public totalSupply;

    /**
     * @inheritdoc IFxGenArt721
     */
    address public randomizer;

    /**
     * @inheritdoc IFxGenArt721
     */
    address public renderer;

    /**
     * @inheritdoc IFxGenArt721
     */
    IssuerInfo public issuerInfo;

    /**
     * @inheritdoc IFxGenArt721
     */
    MetadataInfo public metadataInfo;

    /**
     * @inheritdoc IFxGenArt721
     */
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
     * @dev Modifier for restricting calls to only authorized accounts with given role
     */
    modifier onlyRole(bytes32 _role) {
        if (!IAccessControl(roleRegistry).hasRole(_role, msg.sender)) revert UnauthorizedAccount();
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Initializes FxContractRegistry and FxRoleRegistry
     */
    constructor(
        address _contractRegistry,
        address _roleRegistry
    ) ERC721("FxGenArt721", "FXHASH") EIP712("FxGenArt721", "1") {
        contractRegistry = _contractRegistry;
        roleRegistry = _roleRegistry;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INITIALIZER
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function initialize(
        address _owner,
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
        randomizer = _initInfo.randomizer;
        renderer = _initInfo.renderer;

        _transferOwnership(_owner);
        _setTags(_initInfo.tagIds);
        _registerMinters(_mintInfo);
        setBaseRoyalties(_royaltyReceivers, _basisPoints);

        emit ProjectInitialized(_initInfo.primaryReceiver, _projectInfo, _metadataInfo, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function burn(uint256 _tokenId) external whenNotPaused {
        if (!issuerInfo.projectInfo.burnEnabled) revert BurnInactive();
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function mintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.mintEnabled) revert MintInactive();
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function mintRandom(address _to, uint256 _amount) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.mintEnabled) revert MintInactive();
        for (uint256 i; i < _amount; ++i) {
            _mintRandom(_to, ++totalSupply);
        }
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external {
        if (msg.sender != randomizer) revert NotAuthorized();
        genArtInfo[_tokenId].seed = _seed;
        emit SeedFulfilled(randomizer, _tokenId, _seed);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function ownerMintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused {
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function ownerMintRandom(address _to) external onlyOwner whenNotPaused {
        _mintRandom(_to, ++totalSupply);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function reduceSupply(uint120 _supply) external onlyOwner {
        if (_supply >= issuerInfo.projectInfo.maxSupply || _supply < totalSupply) revert InvalidAmount();
        issuerInfo.projectInfo.maxSupply = _supply;
        if (_supply == 0) emit ProjectDeleted();
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function registerMinters(MintInfo[] calldata _mintInfo) external onlyOwner {
        if (issuerInfo.projectInfo.mintEnabled) revert MintActive();

        // Unregisters all current minters
        for (uint256 i; i < issuerInfo.activeMinters.length; ++i) {
            address minter = issuerInfo.activeMinters[i];
            issuerInfo.minters[minter] = false;
        }

        // Resets array state of active minters
        delete issuerInfo.activeMinters;

        // Registers new minters
        _registerMinters(_mintInfo);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function toggleBurn() external onlyOwner {
        issuerInfo.projectInfo.burnEnabled = !issuerInfo.projectInfo.burnEnabled;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function toggleMint() external onlyOwner {
        issuerInfo.projectInfo.mintEnabled = !issuerInfo.projectInfo.mintEnabled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setBaseURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE) {
        bytes32 digest = generateTypedDataHash(SET_BASE_URI_TYPEHASH, _uri);
        _verifySignature(digest, _signature);
        metadataInfo.baseURI = _uri;
        emit BatchMetadataUpdate(1, totalSupply);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setContractURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE) {
        bytes32 digest = generateTypedDataHash(SET_CONTRACT_URI_TYPEHASH, _uri);
        _verifySignature(digest, _signature);
        issuerInfo.projectInfo.contractURI = _uri;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setImageURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE) {
        bytes32 digest = generateTypedDataHash(SET_IMAGE_URI_TYPEHASH, _uri);
        _verifySignature(digest, _signature);
        metadataInfo.imageURI = _uri;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setRandomizer(address _randomizer) external onlyRole(ADMIN_ROLE) {
        randomizer = _randomizer;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setRenderer(address _renderer) external onlyRole(ADMIN_ROLE) {
        renderer = _renderer;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                MODERATOR FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function setTags(uint256[] calldata _tagIds) external onlyRole(TOKEN_MODERATOR_ROLE) {
        _setTags(_tagIds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function contractURI() external view returns (string memory) {
        return issuerInfo.projectInfo.contractURI;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function generateTypedDataHash(bytes32 _typeHash, string calldata _uri) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(_typeHash, _uri));
        return _hashTypedDataV4(structHash);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function isMinter(address _minter) public view returns (bool) {
        return issuerInfo.minters[_minter];
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function remainingSupply() public view returns (uint256) {
        return issuerInfo.projectInfo.maxSupply - totalSupply;
    }

    /**
     * @inheritdoc ERC721
     */
    function name() public view override returns (string memory) {
        return name_;
    }

    /**
     * @inheritdoc ERC721
     */
    function symbol() public view override returns (string memory) {
        return symbol_;
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        bytes memory data = abi.encode(issuerInfo.projectInfo, metadataInfo, genArtInfo[_tokenId]);
        return IRenderer(renderer).tokenURI(_tokenId, data);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints single token to given account using fxParams as input
     */
    function _mintParams(address _to, uint256 _tokenId, bytes calldata _fxParams) internal {
        if (issuerInfo.projectInfo.inputSize < _fxParams.length) revert InvalidInputSize();
        _mint(_to, _tokenId);
        genArtInfo[_tokenId].fxParams = _fxParams;
    }

    /**
     * @dev Mints single token to given account using randomly generated seed
     */
    function _mintRandom(address _to, uint256 _tokenId) internal {
        _mint(_to, _tokenId);
        IRandomizer(randomizer).requestRandomness(_tokenId);
    }

    /**
     * @dev Registers arbitrary number of minter contracts and sets their reserves
     */
    function _registerMinters(MintInfo[] calldata _mintInfo) internal {
        address minter;
        uint128 totalAllocation;
        ReserveInfo memory reserveInfo;
        (uint256 lockTime, , ) = IFxContractRegistry(contractRegistry).configInfo();
        lockTime = _isVerified(owner()) ? 0 : lockTime;
        unchecked {
            for (uint256 i; i < _mintInfo.length; ++i) {
                minter = _mintInfo[i].minter;
                reserveInfo = _mintInfo[i].reserveInfo;
                if (!IAccessControl(roleRegistry).hasRole(MINTER_ROLE, minter)) revert UnauthorizedMinter();
                if (reserveInfo.startTime < block.timestamp + lockTime) revert InvalidStartTime();
                if (reserveInfo.endTime < reserveInfo.startTime) revert InvalidEndTime();

                issuerInfo.minters[minter] = true;
                issuerInfo.activeMinters.push(minter);
                totalAllocation += reserveInfo.allocation;

                IMinter(minter).setMintDetails(reserveInfo, _mintInfo[i].params);
            }
        }

        if (issuerInfo.projectInfo.maxSupply != OPEN_EDITION_SUPPLY) {
            if (totalAllocation > remainingSupply()) revert AllocationExceeded();
        }
    }

    /**
     * @dev Emits event for setting the project tag descriptions
     */
    function _setTags(uint256[] calldata _tagIds) internal {
        emit ProjectTags(_tagIds);
    }

    /**
     * @dev Checks if creator is verified by the system
     */
    function _isVerified(address _creator) internal view returns (bool) {
        return (IAccessControl(roleRegistry).hasRole(VERIFIED_USER_ROLE, _creator));
    }

    /**
     * @dev Verifies creator signature for metadata updates
     */
    function _verifySignature(bytes32 _digest, bytes calldata _signature) internal view {
        (uint8 v, bytes32 r, bytes32 s) = abi.decode(_signature, (uint8, bytes32, bytes32));
        address signer = ECDSA.recover(_digest, v, r, s);
        if (signer != owner()) revert NotOwner();
    }

    /**
     * @inheritdoc ERC721
     */
    function _exists(uint256 _tokenId) internal view override(ERC721, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }
}
