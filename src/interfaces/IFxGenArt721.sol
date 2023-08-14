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
 * @param enabled Active status of project
 * @param codexId ID of codex info
 * @param supply Maximum supply of tokens
 * @param contractData Contract metadata of project
 * @param tokenMetadata Token metadata scripts
 */
struct ProjectInfo {
    bool enabled;
    uint120 codexId;
    uint128 supply;
    string contractData;
    TokenData tokenData;
}

/**
 * @param baseURI Base URI of metadata pointer
 * @param animation List of HTML head and body tags for building onchain scripts
 * @param attributes List of key value pairs for token attributes
 */
struct TokenData {
    string baseURI;
    HTMLRequest animationURL;
    HTMLRequest attributes;
}

/**
 * @param fxParams Randon sequence of string bytes in fixed length
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
     * @notice Error thrown when caller does not have minter role
     */
    error UnauthorizedMinter();

    /**
     * @notice Error thrown when minter is not registered on token contract
     */
    error UnregisteredMinter();

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
     * @notice Allows owner to mint tokens to given account
     * @dev Public mint must be disabled
     * @param _to Address being minted to
     */
    function ownerMint(address _to) external;

    /**
     * @notice Allows any minter contract to mint an arbitrary amount of tokens to a given account
     * @param _to Address being minted to
     * @param _amount Amount of tokens being minted
     */
    function publicMint(address _to, uint256 _amount) external;

    /**
     * @notice Sets the new Renderer contract
     * @param _renderer Address of the Renderer contract
     */
    function setRenderer(address _renderer) external;

    /**
     * @notice Enables and disables the public mint
     */
    function toggleMint() external;

    /**
     * @notice Returns the address of the ContractRegistry contract
     */
    function contractRegistry() external view returns (address);

    /**
     * @notice Returns contract-level metadata for storefront marketplaces
     */
    function contractURI() external view returns (string memory);

    /**
     * @notice Gets the generative art information for a given token
     * @param _tokenId ID of the token
     * @return FxParams and Seed
     */
    function genArtInfo(uint96 _tokenId) external view returns (bytes memory, bytes32);

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
     * @notice Returns the address of the Renderer contract
     */
    function renderer() external view returns (address);

    /**
     * @notice Returns address of the RoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Returns the current total supply of tokens
     */
    function totalSupply() external view returns (uint96);
}
