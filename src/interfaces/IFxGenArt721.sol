// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {GenArtInfo, InitInfo, IssuerInfo, MetadataInfo, MintInfo, ProjectInfo, ReserveInfo} from "src/lib/Structs.sol";
import {ISeedConsumer} from "src/interfaces/ISeedConsumer.sol";
import {IToken} from "src/interfaces/IToken.sol";

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
     * @notice Event emitted when the base URI is updated
     * @param _uri Decoded content identifier of metadata pointer
     */
    event BaseURIUpdated(bytes _uri);

    /**
     * @notice Event emitted when burn is toggled
     * @param _enabled Flag status of burn
     */
    event BurnEnabled(bool indexed _enabled);

    /**
     * @notice Event emitted when minted is toggled
     * @param _enabled Flag status of mint
     */
    event MintEnabled(bool indexed _enabled);

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
     * @notice Event emitted when the primary receiver address is updated
     * @param _receiver Address of the new primary receiver account
     */
    event PrimaryReceiverUpdated(address indexed _receiver);

    /**
     * @notice Event emitted when project tags are set
     * @param _tagIds Array of tag IDs describing the project
     */
    event ProjectTags(uint256[] indexed _tagIds);

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

    /**
     * @notice Event emitted when onchain data of project is updated
     * @param _data Bytes-encoded metadata
     */
    event OnchainDataUpdated(bytes _data);

    /**
     * @notice Event emitted when maximum supply is reduced
     * @param _prevSupply Amount of previous supply
     * @param _newSupply Amount of new supply
     */
    event SupplyReduced(uint120 indexed _prevSupply, uint120 indexed _newSupply);

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
     * @notice Error thrown when the fee receiver address is not included in the receiver allocations
     */
    error FeeReceiverMissing();

    /**
     * @notice Error thrown when remaining supply is zero
     */
    error InsufficientSupply();

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
     * @notice Error thrown when supply is remaining
     */
    error SupplyRemaining();

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

    /*
     * @notice Returns the list of minter contracts currently active on the token
     */
    function activeMinters() external view returns (address[] memory);

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
     * @notice Generates typed data hash for setting project metadata onchain
     * @param _data Bytes-encoded onchain data
     * @return Typed data hash
     */
    function generateOnchainDataHash(bytes calldata _data) external view returns (bytes32);

    /**
     * @notice Generates typed data hash for setting the primary receiver address
     * @param _receiver Address of the new primary receiver account
     * @return Typed data hash
     */
    function generatePrimaryReceiverHash(address _receiver) external view returns (bytes32);

    /**
     * @notice Initializes new generative art project
     * @param _owner Address of token proxy owner
     * @param _initInfo Initialization information set on project creation
     * @param _projectInfo Project information
     * @param _metadataInfo Metadata information
     * @param _mintInfo Array of authorized minter contracts and their reserves
     * @param _royaltyReceivers Array of addresses receiving royalties
     * @param _allocations Array of basis points for calculating royalty shares
     * @param _basisPoints basis points for calculating royalty shares
     */
    function initialize(
        address _owner,
        InitInfo calldata _initInfo,
        ProjectInfo calldata _projectInfo,
        MetadataInfo calldata _metadataInfo,
        MintInfo[] calldata _mintInfo,
        address[] calldata _royaltyReceivers,
        uint32[] calldata _allocations,
        uint96 _basisPoints
    ) external;

    /**
     * @notice Gets the authorization status for the given minter contract
     * @param _minter Address of the minter contract
     * @return Authorization status
     */
    function isMinter(address _minter) external view returns (bool);

    /**
     * @notice Returns the issuer information of the project (primaryReceiver, ProjectInfo)
     */
    function issuerInfo() external view returns (address, ProjectInfo memory);

    /**
     * @notice Returns the metadata information of the project (baseURI, onchainPointer)
     */
    function metadataInfo() external view returns (bytes memory, address);

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
    function registerMinters(MintInfo[] memory _mintInfo) external;

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
     * @notice Sets the base royalties for all secondary token sales
     * @param _receivers Array of addresses receiving royalties
     * @param _allocations Array of allocations used to calculate royalty payments
     * @param _basisPoints basis points used to calculate royalty payments
     */
    function setBaseRoyalties(
        address[] calldata _receivers,
        uint32[] calldata _allocations,
        uint96 _basisPoints
    ) external;

    /**
     * @notice Sets the new URI of the token metadata
     * @param _uri Decoded content identifier of metadata pointer
     */
    function setBaseURI(bytes calldata _uri) external;

    /**
     * @notice Sets the onchain data of the project metadata
     * @param _data Bytes-encoded metadata
     * @param _signature Signature of creator used to verify metadata update
     */
    function setOnchainData(bytes calldata _data, bytes calldata _signature) external;

    /**
     * @notice Sets the primary receiver address for token royalties
     * @param _receiver Address of the new primary receiver account
     * @param _signature Signature of creator used to verify receiver update
     */
    function setPrimaryReceiver(address _receiver, bytes calldata _signature) external;

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
