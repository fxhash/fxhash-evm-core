# IFxGenArt721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/interfaces/IFxGenArt721.sol)

**Inherits:**
[ISeedConsumer](/src/interfaces/ISeedConsumer.sol/interface.ISeedConsumer.md), [IToken](/src/interfaces/IToken.sol/interface.IToken.md)

**Author:**
fx(hash)

ERC-721 token for generative art projects created on fxhash


## Functions
### activeMinters


```solidity
function activeMinters() external view returns (address[] memory);
```

### burn

Burns token ID from the circulating supply


```solidity
function burn(uint256 _tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### contractRegistry

Returns address of the FxContractRegistry contract


```solidity
function contractRegistry() external view returns (address);
```

### contractURI

Returns contract-level metadata for storefront marketplaces


```solidity
function contractURI() external view returns (string memory);
```

### fulfillSeedRequest

Fullfills the random seed request on the FxGenArt721 token contract


```solidity
function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the random seed|


### genArtInfo

Mapping of token ID to GenArtInfo struct (minter, seed, fxParams)


```solidity
function genArtInfo(uint256 _tokenId) external view returns (address, bytes32, bytes memory);
```

### generateOnchainPointerHash

Generates typed data hash for setting project metadata onchain


```solidity
function generateOnchainPointerHash(bytes calldata _data) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_data`|`bytes`|Bytes-encoded onchain data|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Typed data hash|


### generateRendererHash

Generates typed data hash for setting the primary receiver address


```solidity
function generateRendererHash(address _renderer) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the new renderer contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Typed data hash|


### initialize

Initializes new generative art project


```solidity
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
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of token proxy owner|
|`_initInfo`|`InitInfo`|Initialization information set on project creation|
|`_projectInfo`|`ProjectInfo`|Project information|
|`_metadataInfo`|`MetadataInfo`|Metadata information|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|
|`_royaltyReceivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocation amounts for calculating royalty shares|
|`_basisPoints`|`uint96`|Total allocation scalar for calculating royalty shares|


### isMinter

Gets the authorization status for the given minter contract


```solidity
function isMinter(address _minter) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the minter contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Authorization status|


### issuerInfo

Returns the issuer information of the project (primaryReceiver, ProjectInfo)


```solidity
function issuerInfo() external view returns (address, ProjectInfo memory);
```

### metadataInfo

Returns the metadata information of the project (baseURI, onchainPointer)


```solidity
function metadataInfo() external view returns (bytes memory, address);
```

### mint

Mints arbitrary number of tokens

*Only callable by registered minter contracts*


```solidity
function mint(address _to, uint256 _amount, uint256 _payment) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving tokens|
|`_amount`|`uint256`|Number of tokens being minted|
|`_payment`|`uint256`|Total payment amount of the transaction|


### mintParams

Mints single fxParams token

*Only callable by registered minter contracts*


```solidity
function mintParams(address _to, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving minted token|
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used as input|


### nonce

Current nonce for admin signatures


```solidity
function nonce() external returns (uint96);
```

### ownerMint

Mints single token with randomly generated seed

*Only callable by contract owner*


```solidity
function ownerMint(address _to) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving token|


### ownerMintParams

Mints single fxParams token

*Only callable by contract owner*


```solidity
function ownerMintParams(address _to, bytes calldata _fxParams) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving minted token|
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used as input|


### pause

Pauses all function executions where modifier is applied


```solidity
function pause() external;
```

### primaryReceiver

Returns address of primary receiver for token sales


```solidity
function primaryReceiver() external view returns (address);
```

### randomizer

Returns the address of the randomizer contract


```solidity
function randomizer() external view returns (address);
```

### reduceSupply

Reduces maximum supply of collection


```solidity
function reduceSupply(uint120 _supply) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_supply`|`uint120`|Maximum supply amount|


### registerMinters

Registers minter contracts with resereve info


```solidity
function registerMinters(MintInfo[] memory _mintInfo) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mintInfo`|`MintInfo[]`|Mint information of token reserves|


### remainingSupply

Returns the remaining supply of tokens left to mint


```solidity
function remainingSupply() external view returns (uint256);
```

### renderer

Returns the address of the Renderer contract


```solidity
function renderer() external view returns (address);
```

### roleRegistry

Returns the address of the FxRoleRegistry contract


```solidity
function roleRegistry() external view returns (address);
```

### setBaseRoyalties

Sets the base royalties for all secondary token sales


```solidity
function setBaseRoyalties(address[] calldata _receivers, uint32[] calldata _allocations, uint96 _basisPoints)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocations used to calculate royalty payments|
|`_basisPoints`|`uint96`|basis points used to calculate royalty payments|


### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(bytes calldata _uri) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`bytes`|Decoded content identifier of metadata pointer|


### setBurnEnabled

Sets flag status of public burn to enabled or disabled


```solidity
function setBurnEnabled(bool _flag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of burn|


### setMintEnabled

Sets flag status of public mint to enabled or disabled


```solidity
function setMintEnabled(bool _flag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of mint|


### setOnchainPointer

Sets the onchain pointer for reconstructing project metadata onchain


```solidity
function setOnchainPointer(bytes calldata _onchainData, bytes calldata _signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_onchainData`|`bytes`|Bytes-encoded metadata|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setPrimaryReceivers

Sets the primary receiver address for primary sale proceeds


```solidity
function setPrimaryReceivers(address[] calldata _receivers, uint32[] calldata _allocations) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address[]`|Array of addresses receiving shares from primary sales|
|`_allocations`|`uint32[]`|Array of allocation amounts for calculating primary sales shares|


### setRandomizer

Sets the new randomizer contract


```solidity
function setRandomizer(address _randomizer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_randomizer`|`address`|Address of the randomizer contract|


### setRenderer

Sets the new renderer contract


```solidity
function setRenderer(address _renderer, bytes calldata _signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the renderer contract|
|`_signature`|`bytes`|Signature of creator used to verify renderer update|


### setTags

Emits an event for setting tag descriptions for the project


```solidity
function setTags(uint256[] calldata _tagIds) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tagIds`|`uint256[]`|Array of tag IDs describing the project|


### totalSupply

Returns the current circulating supply of tokens


```solidity
function totalSupply() external view returns (uint96);
```

### unpause

Unpauses all function executions where modifier is applied


```solidity
function unpause() external;
```

## Events
### BaseURIUpdated
Event emitted when the base URI is updated


```solidity
event BaseURIUpdated(bytes _uri);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`bytes`|Decoded content identifier of metadata pointer|

### BurnEnabled
Event emitted when public burn is enabled or disabled


```solidity
event BurnEnabled(bool indexed _flag);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of burn|

### MintEnabled
Event emitted when public mint is enabled or disabled


```solidity
event MintEnabled(bool indexed _flag);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of mint|

### ProjectDeleted
Event emitted when project is deleted only once supply is set to zero


```solidity
event ProjectDeleted();
```

### ProjectInitialized
Event emitted when new project is initialized


```solidity
event ProjectInitialized(
    address indexed _primaryReceiver, ProjectInfo _projectInfo, MetadataInfo _metadataInfo, MintInfo[] _mintInfo
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_primaryReceiver`|`address`|Address of splitter contract receiving primary sales|
|`_projectInfo`|`ProjectInfo`|Project information|
|`_metadataInfo`|`MetadataInfo`|Metadata information of token|
|`_mintInfo`|`MintInfo[]`|Array of authorized minter contracts and their reserves|

### PrimaryReceiverUpdated
Event emitted when the primary receiver address is updated


```solidity
event PrimaryReceiverUpdated(address indexed _receiver, address[] _receivers, uint32[] _allocations);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receiver`|`address`|The split address receiving funds on behalf of the users|
|`_receivers`|`address[]`|Array of addresses receiving a portion of the funds in a split|
|`_allocations`|`uint32[]`|Array of allocation shares for the split|

### ProjectTags
Event emitted when project tags are set


```solidity
event ProjectTags(uint256[] indexed _tagIds);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tagIds`|`uint256[]`|Array of tag IDs describing the project|

### RandomizerUpdated
Event emitted when Randomizer contract is updated


```solidity
event RandomizerUpdated(address indexed _randomizer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_randomizer`|`address`|Address of new Randomizer contract|

### RendererUpdated
Event emitted when Renderer contract is updated


```solidity
event RendererUpdated(address indexed _renderer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of new Renderer contract|

### OnchainPointerUpdated
Event emitted when onchain data of project is updated


```solidity
event OnchainPointerUpdated(address _pointer);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pointer`|`address`|SSTORE2 pointer to the onchain data|

### SupplyReduced
Event emitted when maximum supply is reduced


```solidity
event SupplyReduced(uint120 indexed _prevSupply, uint120 indexed _newSupply);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_prevSupply`|`uint120`|Amount of previous supply|
|`_newSupply`|`uint120`|Amount of new supply|

## Errors
### AllocationExceeded
Error thrown when total minter allocation exceeds maximum supply


```solidity
error AllocationExceeded();
```

### BurnInactive
Error thrown when burning is inactive


```solidity
error BurnInactive();
```

### FeeReceiverMissing
Error thrown when the fee receiver address is not included in the receiver allocations


```solidity
error FeeReceiverMissing();
```

### InsufficientSupply
Error thrown when remaining supply is zero


```solidity
error InsufficientSupply();
```

### InvalidAmount
Error thrown when max supply amount is invalid


```solidity
error InvalidAmount();
```

### InvalidInputSize
Error thrown when input size does not match actual byte size of params data


```solidity
error InvalidInputSize();
```

### InvalidStartTime
Error thrown when reserve start time is invalid


```solidity
error InvalidStartTime();
```

### InvalidEndTime
Error thrown when reserve end time is invalid


```solidity
error InvalidEndTime();
```

### InvalidFeeReceiver
Error thrown when the configured fee receiver is not valid


```solidity
error InvalidFeeReceiver();
```

### MintActive
Error thrown when minting is active


```solidity
error MintActive();
```

### MintInactive
Error thrown when minting is inactive


```solidity
error MintInactive();
```

### NotAuthorized
Error thrown when caller is not authorized to execute transaction


```solidity
error NotAuthorized();
```

### NotOwner
Error thrown when signer is not the owner


```solidity
error NotOwner();
```

### SupplyRemaining
Error thrown when supply is remaining


```solidity
error SupplyRemaining();
```

### UnauthorizedAccount
Error thrown when caller does not have the specified role


```solidity
error UnauthorizedAccount();
```

### UnauthorizedMinter
Error thrown when caller does not have minter role


```solidity
error UnauthorizedMinter();
```

### UnregisteredMinter
Error thrown when minter is not registered on token contract


```solidity
error UnregisteredMinter();
```

