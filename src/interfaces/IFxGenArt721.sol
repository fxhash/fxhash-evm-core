// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HTMLRequest} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";

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
 * @param enabled Minting status of project
 * @param onchain Onchain status of project
 * @param supply Maximum supply of tokens
 * @param contractURI Contract URI of project
 */
struct ProjectInfo {
    bool enabled;
    bool onchain;
    uint240 supply;
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
 * @param fxParams Randon sequence of fixed-length bytes
 * @param seed Hash of revealed seed
 */
struct GenArtInfo {
    bytes fxParams;
    bytes32 seed;
}

/**
 * @param minter Address of the minter contract
 * @param reserveInfo Reserve information
 */
struct MintInfo {
    address minter;
    ReserveInfo reserveInfo;
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
interface IFxGenArt721 {
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
     * @param _projectInfo Project information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     */
    event ProjectInitialized(
        address indexed _primaryReceiver, ProjectInfo _projectInfo, MintInfo[] _mintInfo
    );

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

    /// @notice Error thrown when reserve start time is greater than or equal to end time
    error InvalidReserveTime();

    /// @notice Error thrown when minting is inactive
    error MintInactive();

    /// @notice Error thrown when caller is not authorized to execute transaction
    error NotAuthorized();

    /// @notice Error thrown when caller does not have given role
    error UnauthorizedAccount();

    /// @notice Error thrown when caller is not an authorized contract
    error UnauthorizedContract();

    /// @notice Error thrown when caller does not have minter role
    error UnauthorizedMinter();

    /// @notice Error thrown when minter is not registered on token contract
    error UnregisteredMinter();

    /**
     * @notice Burns token ID from the circulating supply
     * @param _tokenId ID of the token
     */
    function burn(uint256 _tokenId) external;

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function initialize(
        address _owner,
        address _primaryReceiver,
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
    function mint(address _to, uint256 _amount) external;

    /**
     * @notice Allows owner to mint tokens to given account
     * @dev Owner can mint at anytime up to supply cap
     * @param _to Address being minted to
     */
    function ownerMint(address _to) external;

    /**
     * @notice Reduces max supply of collection
     * @param _supply Max supply amount
     */
    function reduceSupply(uint240 _supply) external;

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

    /// @notice Toggles public mint from enabled to disabled and vice versa
    function toggleMint() external;

    /// @notice Toggles token metadata from offchain to onchain and vice versa
    function toggleOnchain() external;

    /// @notice Returns the address of the ContractRegistry contract
    function contractRegistry() external view returns (address);

    /// @notice Returns contract-level metadata for storefront marketplaces
    function contractURI() external view returns (string memory);

    /**
     * @notice Gets the generative art information for a given token
     * @param _tokenId ID of the token
     * @return FxParams and Seed
     */
    function genArtInfo(uint256 _tokenId) external view returns (bytes memory, bytes32);

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

    /// @notice Returns the remaining supply of tokens left to mint
    function remainingSupply() external view returns (uint256);

    /// @notice Returns the address of the Randomizer contract
    function randomizer() external view returns (address);

    /// @notice Returns the address of the Renderer contract
    function renderer() external view returns (address);

    /// @notice Returns the address of the RoleRegistry contract
    function roleRegistry() external view returns (address);

    /// @notice Returns the current total supply of tokens
    function totalSupply() external view returns (uint96);

    /// @notice Returns the version of the implementatiaon
    function version() external view returns (bytes32);
}
