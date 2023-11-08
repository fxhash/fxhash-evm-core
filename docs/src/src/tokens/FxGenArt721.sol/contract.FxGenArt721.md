# FxGenArt721
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/tokens/FxGenArt721.sol)

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


### issuerInfo
Returns the issuer information of the project (primaryReceiver, ProjectInfo)


```solidity
IssuerInfo public issuerInfo;
```


### metadataInfo
Returns the metadata information of the project (baseURI, imageURI, onchainData)


```solidity
MetadataInfo public metadataInfo;
```


### genArtInfo
Mapping of token ID to GenArtInfo struct (seed, fxParams)


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
    ProjectInfo calldata _projectInfo,
    MetadataInfo calldata _metadataInfo,
    MintInfo[] memory _mintInfo,
    address payable[] calldata _royaltyReceivers,
    uint96[] calldata _basisPoints
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
|`_royaltyReceivers`|`address payable[]`|Array of addresses receiving royalties|
|`_basisPoints`|`uint96[]`|Array of basis points for calculating royalty shares|


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


### toggleBurn

Toggles public burn from disabled to enabled and vice versa


```solidity
function toggleBurn() external onlyOwner;
```

### toggleMint

Toggles public mint from enabled to disabled and vice versa


```solidity
function toggleMint() external onlyOwner;
```

### setBaseURI

Sets the new URI of the token metadata


```solidity
function setBaseURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Base URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setContractURI

Sets the new URI of the contract metadata


```solidity
function setContractURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Contract URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setImageURI

Sets the new URI of the image metadata


```solidity
function setImageURI(string calldata _uri, bytes calldata _signature) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_uri`|`string`|Image URI pointer|
|`_signature`|`bytes`|Signature of creator used to verify metadata update|


### setRandomizer

Sets the new randomizer contract


```solidity
function setRandomizer(address _randomizer) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_randomizer`|`address`|Address of the randomizer contract|


### setRenderer

Sets the new renderer contract


```solidity
function setRenderer(address _renderer) external onlyRole(ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_renderer`|`address`|Address of the renderer contract|


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

### contractURI

Returns contract-level metadata for storefront marketplaces


```solidity
function contractURI() external view returns (string memory);
```

### generateTypedDataHash

Generates typed data hash for given URI


```solidity
function generateTypedDataHash(bytes32 _typeHash, string calldata _uri) public view returns (bytes32);
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


### isMinter

Gets the authorization status for the given minter contract


```solidity
function isMinter(address _minter) public view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minter`|`address`|Address of the minter contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|Authorization status|


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

### _setTags

*Emits event for setting the project tag descriptions*


```solidity
function _setTags(uint256[] calldata _tagIds) internal;
```

### _isVerified

*Checks if creator is verified by the system*


```solidity
function _isVerified(address _creator) internal view returns (bool);
```

### _verifySignature

*Verifies creator signature for metadata updates*


```solidity
function _verifySignature(bytes32 _digest, bytes calldata _signature) internal view;
```

### _exists


```solidity
function _exists(uint256 _tokenId) internal view override(ERC721, RoyaltyManager) returns (bool);
```

