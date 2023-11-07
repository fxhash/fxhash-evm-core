# IFxGenArt721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/interfaces/IFxGenArt721.sol)

**Inherits:**
[ISeedConsumer](/src/interfaces/ISeedConsumer.sol/interface.ISeedConsumer.md), [IToken](/src/interfaces/IToken.sol/interface.IToken.md)

**Author:**
fx(hash)

ERC-721 token for generative art projects created on fxhash


## Functions
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

Mapping of token ID to GenArtInfo struct (seed, fxParams)


```solidity
function genArtInfo(uint256 _tokenId) external view returns (bytes32, bytes memory);
```

### generateTypedDataHash

Generates typed data hash for given URI


```solidity
function generateTypedDataHash(bytes32 _typeHash, string calldata _uri) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_typeHash`|`bytes32`|Bytes|
|`_uri`|`string`|URI of metadata|

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
    address payable[] calldata _royaltyReceivers,
    uint96[] calldata _basisPoints
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
|`_royaltyReceivers`|`address payable[]`|Array of addresses receiving royalties|
|`_basisPoints`|`uint96[]`|Array of basis points for calculating royalty shares|


### isMinter

Gets the authorization status for the given minter contract


```solidity
function isMinter(address _minter) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the minter contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|Authorization status|


### issuerInfo

Returns the issuer information of the project (primaryReceiver, ProjectInfo)


```solidity
function issuerInfo() external view returns (address, ProjectInfo memory);
```

### metadataInfo

Returns the metadata information of the project (baseURI, imageURI, onchainData)


```solidity
function metadataInfo() external view returns (string memory, string memory, bytes memory);
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
function registerMinters(MintInfo[] calldata _mintInfo) external;
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

### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(string calldata _uri, bytes calldata _signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Base URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setContractURI

Sets the new URI of the contract metadata


```solidity
function setContractURI(string calldata _uri, bytes calldata _signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Contract URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setImageURI

Sets the new URI of the image metadata


```solidity
function setImageURI(string calldata _uri, bytes calldata _signature) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Image URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


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
function setRenderer(address _renderer) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the renderer contract|


### setTags

Emits an event for setting tag descriptions for the project


```solidity
function setTags(uint256[] calldata _tagIds) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tagIds`|`uint256[]`|Array of tag IDs describing the project|


### toggleBurn

Toggles public burn from disabled to enabled and vice versa


```solidity
function toggleBurn() external;
```

### toggleMint

Toggles public mint from enabled to disabled and vice versa


```solidity
function toggleMint() external;
```

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
### BurnEnabled
Event emitted when burn is toggled


```solidity
event BurnEnabled(bool indexed _enabled);
```

### MintEnabled
Event emitted when minted is toggled


```solidity
event MintEnabled(bool indexed _enabled);
```

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

### ProjectTags
Event emitted when project tags are set


```solidity
event ProjectTags(uint256[] indexed _tagIds);
```

### RandomizerUpdated
Event emitted when Randomizer contract is updated


```solidity
event RandomizerUpdated(address indexed _randomizer);
```

### RendererUpdated
Event emitted when Renderer contract is updated


```solidity
event RendererUpdated(address indexed _renderer);
```

### SupplyReduced
Event emitted when maximum supply is reduced


```solidity
event SupplyReduced(uint120 indexed _prevSupply, uint120 indexed _newSupply);
```

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

