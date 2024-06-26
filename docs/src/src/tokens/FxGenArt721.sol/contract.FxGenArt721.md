# FxGenArt721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/tokens/FxGenArt721.sol)

**Inherits:**
[IFxGenArt721](/src/interfaces/IFxGenArt721.sol/interface.IFxGenArt721.md), IERC4906, ERC721, EIP712, Initializable, Ownable, Pausable, [RoyaltyManager](/src/tokens/extensions/RoyaltyManager.sol/abstract.RoyaltyManager.md)

**Author:**
fx(hash)

See the documentation in {IFxGenArt721}


## State Variables
### contractRegistry
Returns address of the FxContractRegistry contract


```solidity
address public immutable contractRegistry;
```


### roleRegistry
Returns the address of the FxRoleRegistry contract


```solidity
address public immutable roleRegistry;
```


### nameAndSymbol_
*Packed value of name and symbol where combined length is 30 bytes or less*


```solidity
bytes32 internal nameAndSymbol_;
```


### name_
*Project name*


```solidity
string internal name_;
```


### symbol_
*Project symbol*


```solidity
string internal symbol_;
```


### totalSupply
Returns the current circulating supply of tokens


```solidity
uint96 public totalSupply;
```


### randomizer
Returns the address of the randomizer contract


```solidity
address public randomizer;
```


### renderer
Returns the address of the Renderer contract


```solidity
address public renderer;
```


### nonce
Current nonce for admin signatures


```solidity
uint96 public nonce;
```


### issuerInfo
Returns the issuer information of the project (primaryReceiver, ProjectInfo)


```solidity
IssuerInfo public issuerInfo;
```


### metadataInfo
Returns the metadata information of the project (baseURI, onchainPointer)


```solidity
MetadataInfo public metadataInfo;
```


### genArtInfo
Mapping of token ID to GenArtInfo struct (minter, seed, fxParams)


```solidity
mapping(uint256 => GenArtInfo) public genArtInfo;
```


## Functions
### onlyMinter

*Modifier for restricting calls to only registered minters*


```solidity
modifier onlyMinter();
```

### onlyRole

*Modifier for restricting calls to only authorized accounts with given role*


```solidity
modifier onlyRole(bytes32 _role);
```

### constructor

*Initializes FxContractRegistry and FxRoleRegistry*


```solidity
constructor(address _contractRegistry, address _roleRegistry)
    ERC721("FxGenArt721", "FXHASH")
    EIP712("FxGenArt721", "1");
```

### initialize

Initializes new generative art project


```solidity
function initialize(
    address _owner,
    InitInfo calldata _initInfo,
    ProjectInfo memory _projectInfo,
    MetadataInfo calldata _metadataInfo,
    MintInfo[] calldata _mintInfo,
    address[] calldata _royaltyReceivers,
    uint32[] calldata _allocations,
    uint96 _basisPoints
) external initializer;
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


### burn

Burns token ID from the circulating supply


```solidity
function burn(uint256 _tokenId) external whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


### fulfillSeedRequest


```solidity
function fulfillSeedRequest(uint256 _tokenId, bytes32 _seed) external;
```

### mint


```solidity
function mint(address _to, uint256 _amount, uint256) external onlyMinter whenNotPaused;
```

### mintParams

Mints single fxParams token

*Only callable by registered minter contracts*


```solidity
function mintParams(address _to, bytes calldata _fxParams) external onlyMinter whenNotPaused;
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
function ownerMint(address _to) external onlyOwner whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving token|


### ownerMintParams

Mints single fxParams token

*Only callable by contract owner*


```solidity
function ownerMintParams(address _to, bytes calldata _fxParams) external onlyOwner whenNotPaused;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving minted token|
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used as input|


### reduceSupply

Reduces maximum supply of collection


```solidity
function reduceSupply(uint120 _supply) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_supply`|`uint120`|Maximum supply amount|


### registerMinters

Registers minter contracts with resereve info


```solidity
function registerMinters(MintInfo[] memory _mintInfo) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mintInfo`|`MintInfo[]`|Mint information of token reserves|


### setBaseRoyalties

Sets the base royalties for all secondary token sales


```solidity
function setBaseRoyalties(address[] calldata _receivers, uint32[] calldata _allocations, uint96 _basisPoints)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocations used to calculate royalty payments|
|`_basisPoints`|`uint96`|basis points used to calculate royalty payments|


### setBurnEnabled

Sets flag status of public burn to enabled or disabled


```solidity
function setBurnEnabled(bool _flag) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of burn|


### setMintEnabled

Sets flag status of public mint to enabled or disabled


```solidity
function setMintEnabled(bool _flag) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_flag`|`bool`|Status of mint|


### setOnchainPointer

Sets the onchain pointer for reconstructing project metadata onchain


```solidity
function setOnchainPointer(bytes calldata _onchainData, bytes calldata _signature) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_onchainData`|`bytes`|Bytes-encoded metadata|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setPrimaryReceivers

Sets the primary receiver address for primary sale proceeds


```solidity
function setPrimaryReceivers(address[] calldata _receivers, uint32[] calldata _allocations) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address[]`|Array of addresses receiving shares from primary sales|
|`_allocations`|`uint32[]`|Array of allocation amounts for calculating primary sales shares|


### setRenderer

Sets the new renderer contract


```solidity
function setRenderer(address _renderer, bytes calldata _signature) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the renderer contract|
|`_signature`|`bytes`|Signature of creator used to verify renderer update|


### setRandomizer

Sets the new randomizer contract


```solidity
function setRandomizer(address _randomizer) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_randomizer`|`address`|Address of the randomizer contract|


### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(bytes calldata _uri) external onlyRole(METADATA_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`bytes`|Decoded content identifier of metadata pointer|


### pause

Pauses all function executions where modifier is applied


```solidity
function pause() external onlyRole(MODERATOR_ROLE);
```

### setTags

Emits an event for setting tag descriptions for the project


```solidity
function setTags(uint256[] calldata _tagIds) external onlyRole(MODERATOR_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tagIds`|`uint256[]`|Array of tag IDs describing the project|


### unpause

Unpauses all function executions where modifier is applied


```solidity
function unpause() external onlyRole(MODERATOR_ROLE);
```

### activeMinters


```solidity
function activeMinters() external view returns (address[] memory);
```

### contractURI

Returns contract-level metadata for storefront marketplaces


```solidity
function contractURI() external view returns (string memory);
```

### primaryReceiver


```solidity
function primaryReceiver() external view returns (address);
```

### generateOnchainPointerHash

Generates typed data hash for setting project metadata onchain


```solidity
function generateOnchainPointerHash(bytes calldata _data) public view returns (bytes32);
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
function generateRendererHash(address _renderer) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the new renderer contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Typed data hash|


### isMinter

Gets the authorization status for the given minter contract


```solidity
function isMinter(address _minter) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the minter contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Authorization status|


### remainingSupply

Returns the remaining supply of tokens left to mint


```solidity
function remainingSupply() public view returns (uint256);
```

### name


```solidity
function name() public view override returns (string memory);
```

### symbol


```solidity
function symbol() public view override returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId) public view override returns (string memory);
```

### _mintParams

*Mints single token to given account using fxParams as input*


```solidity
function _mintParams(address _to, uint256 _tokenId, bytes calldata _fxParams) internal;
```

### _mintRandom

*Mints single token to given account using randomly generated seed as input*


```solidity
function _mintRandom(address _to, uint256 _tokenId) internal;
```

### _registerMinters

*Registers arbitrary number of minter contracts and sets their reserves*


```solidity
function _registerMinters(MintInfo[] memory _mintInfo) internal;
```

### _setBaseRoyalties

*Sets receivers and allocations for base royalties of token sales*


```solidity
function _setBaseRoyalties(address[] calldata _receivers, uint32[] calldata _allocations, uint96 _basisPoints)
    internal
    override;
```

### _setPrimaryReceiver

*Sets primary receiver address for token sales*


```solidity
function _setPrimaryReceiver(address[] calldata _receivers, uint32[] calldata _allocations) internal;
```

### _setNameAndSymbol

*Packs name and symbol into single slot if combined length is 30 bytes or less*


```solidity
function _setNameAndSymbol(string calldata _name, string calldata _symbol) internal;
```

### _setOnchainPointer

*Sets the onchain pointer for reconstructing metadata onchain*


```solidity
function _setOnchainPointer(bytes calldata _onchainData) internal;
```

### _setTags

*Emits event for setting the project tag descriptions*


```solidity
function _setTags(uint256[] calldata _tagIds) internal;
```

### _verifySignature

*Verifies that a signature was generated for the computed digest*


```solidity
function _verifySignature(bytes32 _digest, bytes calldata _signature) internal;
```

### _isVerified

*Checks if creator is verified by the system*


```solidity
function _isVerified(address _creator) internal view returns (bool);
```

### _checkFeeReceiver

*Checks if fee receiver and allocation amount are included in their respective arrays*


```solidity
function _checkFeeReceiver(
    address[] calldata _receivers,
    uint32[] calldata _allocations,
    address _feeReceiver,
    uint32 _feeAllocation
) internal pure;
```

### _exists

*Returns if token `id` exists.*


```solidity
function _exists(uint256 _tokenId) internal view override(ERC721, RoyaltyManager) returns (bool);
```

