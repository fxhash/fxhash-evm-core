// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {EIP712} from "openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC721} from "openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Initializable} from "openzeppelin-upgradeable/contracts/proxy/utils/Initializable.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {Pausable} from "openzeppelin/contracts/security/Pausable.sol";
import {RoyaltyManager} from "src/tokens/extensions/RoyaltyManager.sol";
import {SignatureChecker} from "openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

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
    using SignatureChecker for address;

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
     * @dev Packed value of name and symbol where combined length is 30 bytes or less
     */
    bytes32 internal nameAndSymbol_;

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
        issuerInfo.primaryReceiver = _initInfo.primaryReceiver;
        issuerInfo.projectInfo = _projectInfo;
        metadataInfo = _metadataInfo;
        randomizer = _initInfo.randomizer;
        renderer = _initInfo.renderer;

        _initializeOwner(_owner);
        _registerMinters(_mintInfo);
        _setBaseRoyalties(_royaltyReceivers, _basisPoints);
        _setNameAndSymbol(_initInfo.name, _initInfo.symbol);
        _setTags(_initInfo.tagIds);

        emit ProjectInitialized(_initInfo.primaryReceiver, _projectInfo, _metadataInfo, _mintInfo);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function burn(uint256 _tokenId) external whenNotPaused {
        if (!issuerInfo.projectInfo.burnEnabled) revert BurnInactive();
        if (!_isApprovedOrOwner(msg.sender, _tokenId)) revert NotAuthorized();
        _burn(_tokenId);
        --totalSupply;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external {
        if (msg.sender != randomizer) revert NotAuthorized();
        genArtInfo[_tokenId].seed = _seed;
        emit SeedFulfilled(randomizer, _tokenId, _seed);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function mint(address _to, uint256 _amount, uint256 /* _payment */) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.mintEnabled) revert MintInactive();
        uint96 currentId = totalSupply;
        unchecked {
            for (uint256 i; i < _amount; ++i) {
                _mintRandom(_to, ++currentId);
            }
        }
        totalSupply = currentId;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function mintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused {
        if (!issuerInfo.projectInfo.mintEnabled) revert MintInactive();
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function ownerMint(address _to) external onlyOwner whenNotPaused {
        _mintRandom(_to, ++totalSupply);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function ownerMintParams(address _to, bytes calldata _fxParams) external onlyOwner whenNotPaused {
        _mintParams(_to, ++totalSupply, _fxParams);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function reduceSupply(uint120 _supply) external onlyOwner {
        uint120 prevSupply = issuerInfo.projectInfo.maxSupply;
        if (_supply >= prevSupply || _supply < totalSupply) revert InvalidAmount();
        issuerInfo.projectInfo.maxSupply = _supply;
        if (_supply == 0) emit ProjectDeleted();
        emit SupplyReduced(prevSupply, _supply);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function registerMinters(MintInfo[] memory _mintInfo) external onlyOwner {
        if (issuerInfo.projectInfo.mintEnabled) revert MintActive();

        // Caches array length
        uint256 length = issuerInfo.activeMinters.length;

        // Unregisters all current minters
        for (uint256 i; i < length; ) {
            address minter = issuerInfo.activeMinters[i];
            issuerInfo.minters[minter] = FALSE;
            unchecked {
                ++i;
            }
        }

        // Deletes current list of active minters
        delete issuerInfo.activeMinters;

        // Registers new minters
        _registerMinters(_mintInfo);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function toggleBurn() external onlyOwner {
        if (remainingSupply() == 0) revert SupplyRemaining();
        issuerInfo.projectInfo.burnEnabled = !issuerInfo.projectInfo.burnEnabled;
        emit BurnEnabled(issuerInfo.projectInfo.burnEnabled);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function toggleMint() external onlyOwner {
        issuerInfo.projectInfo.mintEnabled = !issuerInfo.projectInfo.mintEnabled;
        emit MintEnabled(issuerInfo.projectInfo.mintEnabled);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function setOnchainData(bytes calldata _data, bytes calldata _signature) external onlyRole(ADMIN_ROLE) {
        bytes32 digest = generateOnchainDataHash(_data);
        _verifySignature(digest, _signature);
        metadataInfo.onchainData = _data;
        emit OnchainDataUpdated(_data);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setRandomizer(address _randomizer) external onlyRole(ADMIN_ROLE) {
        randomizer = _randomizer;
        emit RandomizerUpdated(_randomizer);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setRenderer(address _renderer) external onlyRole(ADMIN_ROLE) {
        renderer = _renderer;
        emit RendererUpdated(_renderer);
        emit BatchMetadataUpdate(1, totalSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                METADATA FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function setBaseURI(bytes calldata _uri) external onlyRole(METADATA_ROLE) {
        metadataInfo.baseURI = _uri;
        emit BaseURIUpdated(_uri);
        emit BatchMetadataUpdate(1, totalSupply);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                MODERATOR FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function pause() external onlyRole(MODERATOR_ROLE) {
        _pause();
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function setTags(uint256[] calldata _tagIds) external onlyRole(MODERATOR_ROLE) {
        _setTags(_tagIds);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function unpause() external onlyRole(MODERATOR_ROLE) {
        _unpause();
    }

    /*//////////////////////////////////////////////////////////////////////////
                                READ FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFxGenArt721
     */
    function contractURI() external view returns (string memory) {
        (, , string memory defaultMetadataURI) = IFxContractRegistry(contractRegistry).configInfo();
        return IRenderer(renderer).contractURI(defaultMetadataURI);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function activeMinters() external view returns (address[] memory) {
        return issuerInfo.activeMinters;
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function generateOnchainDataHash(bytes calldata _data) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(SET_ONCHAIN_DATA_TYPEHASH, _data));
        return _hashTypedDataV4(structHash);
    }

    /**
     * @inheritdoc IFxGenArt721
     */
    function isMinter(address _minter) public view returns (bool) {
        return issuerInfo.minters[_minter] == TRUE;
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
        (string memory packedName, ) = LibString.unpackTwo(nameAndSymbol_);
        return (nameAndSymbol_ == bytes32(0)) ? name_ : packedName;
    }

    /**
     * @inheritdoc ERC721
     */
    function symbol() public view override returns (string memory) {
        (, string memory packedSymbol) = LibString.unpackTwo(nameAndSymbol_);
        return (nameAndSymbol_ == bytes32(0)) ? symbol_ : packedSymbol;
    }

    /**
     * @inheritdoc ERC721
     */
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        _requireMinted(_tokenId);
        (, , string memory defaultMetadataURI) = IFxContractRegistry(contractRegistry).configInfo();
        bytes memory data = abi.encode(defaultMetadataURI, metadataInfo, genArtInfo[_tokenId]);
        return IRenderer(renderer).tokenURI(_tokenId, data);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Mints single token to given account using fxParams as input
     */
    function _mintParams(address _to, uint256 _tokenId, bytes calldata _fxParams) internal {
        if (remainingSupply() == 0) revert InsufficientSupply();
        if (issuerInfo.projectInfo.inputSize < _fxParams.length) revert InvalidInputSize();
        _mint(_to, _tokenId);
        genArtInfo[_tokenId].fxParams = _fxParams;
    }

    /**
     * @dev Mints single token to given account using randomly generated seed as input
     */
    function _mintRandom(address _to, uint256 _tokenId) internal {
        if (remainingSupply() == 0) revert InsufficientSupply();
        _mint(_to, _tokenId);
        IRandomizer(randomizer).requestRandomness(_tokenId);
    }

    /**
     * @dev Registers arbitrary number of minter contracts and sets their reserves
     */
    function _registerMinters(MintInfo[] memory _mintInfo) internal {
        address minter;
        uint64 startTime;
        uint128 totalAllocation;
        uint120 maxSupply = issuerInfo.projectInfo.maxSupply;
        ReserveInfo memory reserveInfo;
        (uint256 lockTime, , ) = IFxContractRegistry(contractRegistry).configInfo();
        lockTime = _isVerified(owner()) ? 0 : lockTime;
        for (uint256 i; i < _mintInfo.length; ++i) {
            minter = _mintInfo[i].minter;
            reserveInfo = _mintInfo[i].reserveInfo;
            startTime = reserveInfo.startTime;
            if (!IAccessControl(roleRegistry).hasRole(MINTER_ROLE, minter)) revert UnauthorizedMinter();
            if (startTime == 0) {
                reserveInfo.startTime = uint64(block.timestamp + lockTime);
            } else if (startTime < block.timestamp + lockTime) {
                revert InvalidStartTime();
            }
            if (reserveInfo.endTime < startTime) revert InvalidEndTime();

            issuerInfo.minters[minter] = TRUE;
            issuerInfo.activeMinters.push(minter);
            if (maxSupply != OPEN_EDITION_SUPPLY) {
                /// keep track of totalAllocation if not open edition
                totalAllocation += reserveInfo.allocation;
            }

            IMinter(minter).setMintDetails(reserveInfo, _mintInfo[i].params);
        }

        if (maxSupply != OPEN_EDITION_SUPPLY) {
            if (totalAllocation > remainingSupply()) revert AllocationExceeded();
        }
    }

    /**
     * @dev Packs name and symbol into single slot if combined length is 30 bytes or less
     */
    function _setNameAndSymbol(string calldata _name, string calldata _symbol) internal {
        bytes32 packed = LibString.packTwo(_name, _symbol);
        if (packed == bytes32(0)) {
            name_ = _name;
            symbol_ = _symbol;
        } else {
            nameAndSymbol_ = packed;
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
        return (IAccessControl(roleRegistry).hasRole(CREATOR_ROLE, _creator));
    }

    /**
     * @inheritdoc ERC721
     */
    function _exists(uint256 _tokenId) internal view override(ERC721, RoyaltyManager) returns (bool) {
        return super._exists(_tokenId);
    }

    /**
     * @dev Verifies creator signature for updating storage through admin setters
     */
    function _verifySignature(bytes32 _digest, bytes calldata _signature) internal view {
        if (!owner().isValidSignatureNow(_digest, _signature)) revert NotOwner();
    }
}
