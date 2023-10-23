// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {HTMLRequest} from "scripty.sol/contracts/scripty/core/ScriptyStructs.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {IToken} from "src/interfaces/IToken.sol";

/*//////////////////////////////////////////////////////////////////////////
                                  STRUCTS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @notice Struct of generative art information
 * - `seed` Hash of seed generated for randomly minted tokens
 * - `fxParams` Random sequence of fixed-length bytes used as token input
 */
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}

/**
 * @notice Struct of initialization information on project creation
 * - `name` Name of project
 * - `symbol` Symbol of project
 * - `primaryReceiver` Address of splitter contract receiving primary sales
 * - `randomizer` Address of Randomizer contract
 * - `renderer` Address of Renderer contract
 * - `tagIds` Array of tag IDs describing the project
 */
struct InitInfo {
    string name;
    string symbol;
    address primaryReceiver;
    address randomizer;
    address renderer;
    uint256[] tagIds;
}

/**
 * @notice Struct of issuer information
 * - `primaryReceiver` Address of splitter contract receiving primary sales
 * - `projectInfo` Project information
 * - `activeMinters` Array of authorized minter contracts used for enumeration
 * - `minters` Mapping of minter contract to authorization status
 */
struct IssuerInfo {
    address primaryReceiver;
    ProjectInfo projectInfo;
    address[] activeMinters;
    mapping(address => uint8) minters;
}

/**
 * @notice Struct of metadata information
 * - `baseURI` CID hash of token metadata
 * - `imageURI` CID hash of token images
 * - `onchainData` Bytes-encoded data rendered onchain
 */
struct MetadataInfo {
    string baseURI;
    string imageURI;
    bytes onchainData;
}

/**
 * @notice Struct of mint information
 * - `minter` Address of the minter contract
 * - `reserveInfo` Reserve information
 * - `params` Optional bytes data decoded inside minter
 */
struct MintInfo {
    address minter;
    ReserveInfo reserveInfo;
    bytes params;
}

/**
 * @notice Struct of project information
 * - `onchain` Flag inidicated if project metadata is rendered onchain
 * - `mintEnabled` Flag inidicating if minting is enabled
 * - `burnEnabled` Flag inidicating if burning is enabled
 * - `inputSize` Maximum input size of fxParams bytes data
 * - `maxSupply` Maximum supply of tokens
 * - `contractURI` CID hash of collection metadata
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
 * @notice Struct of reserve information
 * - `startTime` Start timestamp of minter
 * - `endTime` End timestamp of minter
 * - `allocation` Allocation amount for minter
 */
struct ReserveInfo {
    uint64 startTime;
    uint64 endTime;
    uint128 allocation;
}

/**
 * @title IFxGenArt721
 * @author fx(hash)
 * @notice ERC-721 token for generative art projects created on fxhash
 */
interface IFxGenArt721 is ISeedConsumer, IToken {
    /*//////////////////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Event emitted when project is deleted only once supply is set to zero
     */
    event ProjectDeleted();

    /**
     * @notice Event emitted when new project is initialized
     * @param _primaryReceiver Address of splitter contract receiving primary sales
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information of token
     * @param _mintInfo Array of authorized minter contracts and their reserves
     */
    event ProjectInitialized(
        address indexed _primaryReceiver,
        ProjectInfo _projectInfo,
        MetadataInfo _metadataInfo,
        MintInfo[] _mintInfo
    );

    /**
     * @notice Event emitted when project tags are set
     * @param _tagIds Array of tag IDs describing the project
     */
    event ProjectTags(uint256[] indexed _tagIds);

    /*//////////////////////////////////////////////////////////////////////////
                                  ERRORS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Error thrown when total minter allocation exceeds maximum supply
     */
    error AllocationExceeded();

    /**
     *  @notice Error thrown when burning is inactive
     */
    error BurnInactive();

    /**
     * @notice Error thrown when max supply amount is invalid
     */
    error InvalidAmount();

    /**
     * @notice Error thrown when input size does not match actual byte size of params data
     */
    error InvalidInputSize();

    /**
     * @notice Error thrown when reserve start time is invalid
     */
    error InvalidStartTime();

    /**
     * @notice Error thrown when reserve end time is invalid
     */
    error InvalidEndTime();

    /**
     * @notice Error thrown when minting is active
     */
    error MintActive();

    /**
     *  @notice Error thrown when minting is inactive
     */
    error MintInactive();

    /**
     * @notice Error thrown when caller is not authorized to execute transaction
     */
    error NotAuthorized();

    /**
     * @notice Error thrown when signer is not the owner
     */
    error NotOwner();

    /**
     * @notice Error thrown when caller does not have the specified role
     */
    error UnauthorizedAccount();

    /**
     * @notice Error thrown when caller does not have minter role
     */
    error UnauthorizedMinter();

    /**
     * @notice Error thrown when minter is not registered on token contract
     */
    error UnregisteredMinter();

    /*//////////////////////////////////////////////////////////////////////////
                                  FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns token ID from the circulating supply
     * @param _tokenId ID of the token
     */
    function burn(uint256 _tokenId) external;

    /**
     * @notice Returns address of the FxContractRegistry contract
     */
    function contractRegistry() external view returns (address);

    /**
     * @notice Returns contract-level metadata for storefront marketplaces
     */
    function contractURI() external view returns (string memory);

    /**
     * @inheritdoc ISeedConsumer
     */
    function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;

    /**
     * @notice Mapping of token ID to GenArtInfo struct (seed, fxParams)
     */
    function genArtInfo(uint256 _tokenId) external view returns (bytes32, bytes memory);

    /**
     * @notice Generates typed data hash for given URI
     * @param _typeHash Bytes
     * @param _uri URI of metadata
     * @return Typed data hash
     */
    function generateTypedDataHash(bytes32 _typeHash, string calldata _uri) external view returns (bytes32);

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of token proxy owner
     * @param _initInfo Initialization information set on project creation
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo Array of authorized minter contracts and their reserves
     * @param _royaltyReceivers Array of addresses receiving royalties
     * @param _basisPoints Array of basis points for calculating royalty shares
     */
    function initialize(
        address _owner,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address payable[] calldata _royaltyReceivers,
        uint96[] calldata _basisPoints
    ) external;

    /**
     * @notice Gets the authorization status for the given minter contract
     * @param _minter Address of the minter contract
     * @return Authorization status
     */
    function isMinter(address _minter) external view returns (uint8);

    /**
     * @notice Returns the issuer information of the project (primaryReceiver, ProjectInfo)
     */
    function issuerInfo() external view returns (address, ProjectInfo memory);

    /**
     * @notice Returns the metadata information of the project (baseURI, imageURI, onchainData)
     */
    function metadataInfo() external view returns (string memory, string memory, bytes memory);

    /**
     * @inheritdoc IToken
     */
    function mint(address _to, uint256 _amount, uint256 _payment) external;

    /**
     * @notice Mints single fxParams token
     * @dev Only callable by registered minter contracts
     * @param _to Address receiving minted token
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function mintParams(address _to, bytes calldata _fxParams) external;

    /**
     * @notice Mints single token with randomly generated seed
     * @dev Only callable by contract owner
     * @param _to Address receiving token
     */
    function ownerMint(address _to) external;

    /**
     * @notice Mints single fxParams token
     * @dev Only callable by contract owner
     * @param _to Address receiving minted token
     * @param _fxParams Random sequence of fixed-length bytes used as input
     */
    function ownerMintParams(address _to, bytes calldata _fxParams) external;

    /**
     * @notice Pauses all function executions where modifier is applied
     */
    function pause() external;

    /**
     * @notice Returns the address of the randomizer contract
     */
    function randomizer() external view returns (address);

    /**
     * @notice Reduces maximum supply of collection
     * @param _supply Maximum supply amount
     */
    function reduceSupply(uint120 _supply) external;

    /**
     * @notice Registers minter contracts with resereve info
     * @param _mintInfo Mint information of token reserves
     */
    function registerMinters(MintInfo[] calldata _mintInfo) external;

    /**
     * @notice Returns the remaining supply of tokens left to mint
     */
    function remainingSupply() external view returns (uint256);

    /**
     * @notice Returns the address of the Renderer contract
     */
    function renderer() external view returns (address);

    /**
     * @notice Returns the address of the FxRoleRegistry contract
     */
    function roleRegistry() external view returns (address);

    /**
     * @notice Sets the new URI of the token metadata
     * @param _uri Base URI pointer
     * @param _signature Signature of creator used to verify metadata update
     */
    function setBaseURI(string calldata _uri, bytes calldata _signature) external;

    /**
     * @notice Sets the new URI of the contract metadata
     * @param _uri Contract URI pointer
     * @param _signature Signature of creator used to verify metadata update
     */
    function setContractURI(string calldata _uri, bytes calldata _signature) external;

    /**
     * @notice Sets the new URI of the image metadata
     * @param _uri Image URI pointer
     * @param _signature Signature of creator used to verify metadata update
     */
    function setImageURI(string calldata _uri, bytes calldata _signature) external;

    /**
     * @notice Sets the new randomizer contract
     * @param _randomizer Address of the randomizer contract
     */
    function setRandomizer(address _randomizer) external;

    /**
     * @notice Sets the new renderer contract
     * @param _renderer Address of the renderer contract
     */
    function setRenderer(address _renderer) external;

    /**
     * @notice Emits an event for setting tag descriptions for the project
     * @param _tagIds Array of tag IDs describing the project
     */
    function setTags(uint256[] calldata _tagIds) external;

    /**
     * @notice Toggles public burn from disabled to enabled and vice versa
     */
    function toggleBurn() external;

    /**
     * @notice Toggles public mint from enabled to disabled and vice versa
     */
    function toggleMint() external;

    /**
     * @notice Returns the current circulating supply of tokens
     */
    function totalSupply() external view returns (uint96);

    /**
     * @notice Unpauses all function executions where modifier is applied
     */
    function unpause() external;
}
