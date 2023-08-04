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
     * @notice Error thrown when caller is not an authorized contract
     */
    error UnauthorizedCaller();

    /**
     * @notice Event emitted when new project is initialized
     * @param _projectInfo Project information
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _minters List of authorized minter contracts
     */
    event ProjectInitialized(
        ProjectInfo indexed _projectInfo,
        address indexed _primaryReceiver,
        address[] _minters
    );

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of contract owner
     * @param _configManager Address of ConfigManager contract
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _royaltyReceivers List of addresses receiving royalties
     * @param _basisPoints List of basis points for calculating royalty shares
     * @param _minters List of authorized minter contracts
     */
    function initialize(
        address _owner,
        address _configManager,
        address _primaryReceiver,
        ProjectInfo calldata _projectInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints,
        address[] calldata _minters
    ) external;

    /**
     * @notice Returns the current token ID counter
     */
    function currentId() external view returns (uint96);

    /**
     * @notice Returns the address of the ConfigManager contract
     */
    function configManager() external view returns (address);

    /**
     * @notice Returns the address of the MetadataRenderer contract
     */
    function metadataRenderer() external view returns (address);

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
     * @notice Sets the new MetadataRenderer contract used in tokenURI
     * @param _renderer Address of the MetadataRenderer contract
     */
    function setMetadataRenderer(address _renderer) external;

    /**
     * @notice Gets the authorization status for the given minter
     * @param _minter Address of the minter contract
     * @return Bool authorization status
     */
    function isMinter(address _minter) external view returns (bool);
}
