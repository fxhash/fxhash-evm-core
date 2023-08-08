// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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
 * @param enabled Active status of project
 * @param codexId ID of codex info
 * @param supply Maximum supply of tokens
 * @param metadata Bytes-encoded metadata of project
 * @param labels List of project descriptiom labels
 */
struct ProjectInfo {
    bool enabled;
    uint120 codexId;
    uint128 supply;
    bytes metadata;
    uint16[] labels;
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
 * @param fxParams Randon sequence of string bytes in fixed length
 * @param seed Hash of revealed seed
 * @param offChainPointer URI of offchain metadata pointer
 * @param onChainAttributes List of key value mappings of onchain metadata storage
 */
struct TokenInfo {
    bytes fxParams;
    bytes32 seed;
    string offChainPointer;
    MetadataInfo[] onChainAttributes;
}

/**
 * @param key Attribute key of JSON field
 * @param value Attribute value of JSON field
 */
struct MetadataInfo {
    string key;
    string value;
}

/**
 * @title IFxGenArt721
 * @notice ERC-721 proxy token for Generative Art projects
 */
interface IFxGenArt721 {
    /**
     * @notice Error thrown when total minter allocation exceeds maximum supply
     */
    error AllocationExceeded();

    /**
     * @notice Error thrown when reserve start time is greater than or equal to end time
     */
    error InvalidReserveTime();

    /**
     * @notice Error thrown minting is active
     */
    error MintActive();

    /**
     * @notice Error thrown when minting is inactive
     */
    error MintInactive();

    /**
     * @notice Error thrown when caller is not an authorized contract
     */
    error UnauthorizedContract();

    /**
     * @notice Error thrown when minter is not an authorized contract
     */
    error UnauthorizedMinter();

    /**
     * @notice Event emitted when new project is initialized
     * @param _projectInfo Project information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     */
    event ProjectInitialized(
        ProjectInfo indexed _projectInfo,
        MintInfo[] indexed _mintInfo,
        address indexed _primaryReceiver
    );

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _mintInfo List of authorized minter contracts and their reserves
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     */
    function initialize(
        address _owner,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external;

    /**
     * @notice Allows any minter contract to mint an arbitrary amount of tokens to a given account
     * @param _to Address being minted to
     * @param _amount Amount of tokens being minted
     */
    function publicMint(address _to, uint256 _amount) external;

    /**
     * @notice Allows owner to mint tokens to given account
     * @dev Public mint must be disabled
     * @param _to Address being minted to
     */
    function ownerMint(address _to) external;

    /**
     * @notice Enables and disables the public mint
     */
    function toggleMint() external;

    /**
     * @notice Returns the current total supply of tokens
     */
    function totalSupply() external view returns (uint96);

    /**
     * @notice Returns the address of the ContractRegistry contract
     */
    function contractRegistry() external view returns (address);

    /**
     * @notice Returns address of the RoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Returns the address of the Metadata contract
     */
    function metadata() external view returns (address);

    /**
     * @notice Gets the IssuerInfo of the project
     * @return ProjectInfo and splitter contract address
     */
    function issuerInfo() external view returns (ProjectInfo memory, address);

    /**
     * @notice Gets the generative art information for a given token
     * @param _tokenId ID of the token
     * @return TokenInfo
     */
    function genArtInfo(uint96 _tokenId) external view returns (TokenInfo memory);

    /**
     * @notice Sets the new Metadata contract for renderring tokenURI
     * @param _metadata Address of the Metadata contract
     */
    function setMetadata(address _metadata) external;

    /**
     * @notice Gets the authorization status for the given minter
     * @param _minter Address of the minter contract
     * @return Bool authorization status
     */
    function isMinter(address _minter) external view returns (bool);
}
