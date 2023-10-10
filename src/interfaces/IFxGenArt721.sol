// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HTMLRequest} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";

/**
 * @notice Struct of initialization information on project creation
 * @param name Name of project
 * @param symbol Symbol of project
 * @param primaryReceiver Address of splitter contract receiving primary sales
 * @param randomizer Address of Randomizer contract
 * @param renderer Address of Renderer contract
 * @param tagNames List of tag names describing the project
 */
struct InitInfo {
    string name;
    string symbol;
    address primaryReceiver;
    address randomizer;
    address renderer;
    string[] tagNames;
}

/**
 * @param projectInfo Project information
 * @param primaryReceiver Address of splitter contract receiving primary sales
 * @param minters Mapping of minter contract to authorization status
 */
struct IssuerInfo {
    ProjectInfo projectInfo;
    address primaryReceiver;
    mapping(address => bool) minters;
}

/**
 * @param onchain Onchain status of project
 * @param mintEnabled Minting status of project
 * @param burnEnabled Burning status of project
 * @param inputSize Maximum input size of fxParams bytes data
 * @param maxSupply Maximum supply of tokens
 * @param contractURI Contract URI of project
 */
struct ProjectInfo {
    bool onchain;
    bool mintEnabled;
    bool burnEnabled;
    uint120 maxSupply;
    uint120 inputSize;
    string contractURI;
}

/**
 * @param baseURI CID hash of collection metadata
 * @param imageURI CID hash of collection images
 * @param animation List of HTML script tags for building token animations onchain
 * @param attributes List of HTML script tags for building token attributes onchain
 */
struct MetadataInfo {
    string baseURI;
    string imageURI;
    HTMLRequest animation;
    HTMLRequest attributes;
}

/**
 * @param seed Hash of revealed seed
 * @param fxParams Random sequence of fixed-length bytes
 */
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}

/**
 * @param minter Address of the minter contract
 * @param reserveInfo Reserve information
 * @param params Optional abi.encoded bytes data to pass params to the minter
 */
struct MintInfo {
    address minter;
    ReserveInfo reserveInfo;
    bytes params;
}

/**
 * @param startTime Start timestamp of minter
 * @param endTime End timestamp of minter
 * @param allocation Allocation amount for minter
 */
struct ReserveInfo {
    uint64 startTime;
    uint64 endTime;
    uint128 allocation;
}

/**
 * @title IFxGenArt721
 * @notice ERC-721 proxy token for Generative Art projects
 */
interface IFxGenArt721 is ISeedConsumer {
    /**
     * @notice Event emitted when baseURI is updated
     * @param _uri URI pointer of token metadata
     */
    event BaseURIUpdated(string indexed _uri);

    /**
     * @notice Event emitted when contractURI is updated
     * @param _uri URI pointer of project metadata
     */
    event ContractURIUpdated(string indexed _uri);

    /**
     * @notice Event emitted when imageURI is updated
     * @param _uri URI pointer of token images
     */
    event ImageURIUpdated(string indexed _uri);

    /**
     * @notice Event emitted when new project is initialized
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _metadataInfo List of CIDs/attributes for token metadata
     * @param _mintInfo List of authorized minter contracts and their reserves
     */
    event ProjectInitialized(
        address indexed _primaryReceiver,
        ProjectInfo _projectInfo,
        MetadataInfo _metadataInfo,
        MintInfo[] _mintInfo
    );

    /**
     * @notice Event emitted when project tags are set
     * @param _names List of tag names describing the project
     */
    event ProjectTags(string[] indexed _names);

    /**
     * @notice Event emitted when Randomizer contract is updated
     * @param _randomizer Address of new Randomizer contract
     */
    event RandomizerUpdated(address indexed _randomizer);

    /**
     * @notice Event emitted when Renderer contract is updated
     * @param _renderer Address of new Renderer contract
     */
    event RendererUpdated(address indexed _renderer);

    /// @notice Error thrown when total minter allocation exceeds maximum supply
    error AllocationExceeded();

    /// @notice Error thrown when max supply amount is invalid
    error InvalidAmount();

    /// @notice Error thrown when input size does not match actual byte size of params data
    error InvalidInputSize();

    /// @notice Error thrown when reserve start time is invalid
    error InvalidStartTime();

    /// @notice Error thrown when reserve end time is invalid
    error InvalidEndTime();

    /// @notice Error thrown when burning is inactive
    error BurnInactive();

    /// @notice Error thrown when minting is active
    error MintActive();

    /// @notice Error thrown when minting is inactive
    error MintInactive();

    /// @notice Error thrown when caller is not authorized to execute transaction
    error NotAuthorized();

    /// @notice Error thrown when caller does not have the specified role
    error UnauthorizedAccount();

    /// @notice Error thrown when caller is not a registered contract
    error UnauthorizedContract();

    /// @notice Error thrown when caller does not have minter role
    error UnauthorizedMinter();

    /// @notice Error thrown when minter is not registered on token contract
    error UnregisteredMinter();

    /**
     * @notice Burns token ID from the circulating supply
     * @param _tokenId ID of the token
     */
    // function burn(uint256 _tokenId) external;

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _lockTime Locked time duration from mint start time for unverified users
     * @param _initInfo Initialization information set on project creation
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function initialize(
        address _owner,
        uint256 _lockTime,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external;

    /**
     * @notice Allows any minter contract to mint an arbitrary amount of tokens to a given account
     * @param _to Address being minted to
     * @param _amount Amount of tokens being minted
     */
    function mintRandom(address _to, uint256 _amount) external;

    /**
     * @notice Allows any minter contract to mint a single fxParams token
     * @param _to Address being minted to
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function mintParams(address _to, bytes calldata _fxParams) external;

    /**
     * @notice Allows owner to mint tokens with randomly generated seeds a to given account
     * @dev Owner can mint at anytime up to supply cap
     * @param _to Address being minted to
     */
    function ownerMintRandom(address _to) external;

    /**
     * @notice Allows owner to mint a single fxParams token
     * @param _to Address being minted to
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function ownerMintParams(address _to, bytes calldata _fxParams) external;

    /**
     * @notice Reduces max supply of collection
     * @param _supply Max supply amount
     */
    function reduceSupply(uint120 _supply) external;

    /**
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;

    /**
     * @notice Emits an event for setting tag descriptions for a project
     * @param _names List of tag names describing the project
     */
    function emitTags(string[] calldata _names) external;

    /**
     * @notice Sets the new URI of the token metadata
     * @param _uri Pointer of the metadata
     */
    function setBaseURI(string calldata _uri) external;

    /**
     * @notice Sets the new URI of the contract metadata
     * @param _uri Pointer of the metadata
     */
    function setContractURI(string calldata _uri) external;

    /**
     * @notice Sets the new URI of the image metadata
     * @param _uri Pointer of the metadata
     */
    function setImageURI(string calldata _uri) external;

    /**
     * @notice Sets the new Randomizer contract
     * @param _randomizer Address of the Randomizer contract
     */
    function setRandomizer(address _randomizer) external;

    /**
     * @notice Sets the new Renderer contract
     * @param _renderer Address of the Renderer contract
     */
    function setRenderer(address _renderer) external;

    /**
     * @notice Toggles public burn from disabled to enabled and vice versa
     */
    // function toggleBurn() external;

    /**
     * @notice Toggles public mint from enabled to disabled and vice versa
     */
    function toggleMint() external;

    /**
     * @notice Registers minter contracts with resereve info
     */
    function registerMinters(MintInfo[] calldata _mintInfo) external;

    /**
     * @notice Returns contract-level metadata for storefront marketplaces
     */
    function contractURI() external view returns (string memory);

    /**
     * @notice Gets the generative art information for a given token
     * @param _tokenId ID of the token
     * @return FxParams and Seed
     */
    function genArtInfo(uint256 _tokenId) external view returns (bytes32, bytes memory);

    /**
     * @notice Gets the authorization status for the given minter
     * @param _minter Address of the minter contract
     * @return Bool authorization status
     */
    function isMinter(address _minter) external view returns (bool);

    /**
     * @notice Gets the IssuerInfo of the project
     * @return ProjectInfo and splitter contract address
     */
    function issuerInfo() external view returns (ProjectInfo memory, address);

    /**
     * @notice Gets the MetadataInfo of the project
     * @return baseURI, imageURI, animation and attributes
     */
    function metadataInfo()
        external
        view
        returns (string memory, string memory, HTMLRequest memory, HTMLRequest memory);

    /**
     * @notice Returns the remaining supply of tokens left to mint
     */
    function remainingSupply() external view returns (uint256);

    /**
     * @notice Returns the address of the Randomizer contract
     */
    function randomizer() external view returns (address);

    /**
     * @notice Returns the address of the Renderer contract
     */
    function renderer() external view returns (address);

    /**
     * @notice Returns the address of the RoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Returns the current total supply of tokens
     */
    function totalSupply() external view returns (uint96);
}
