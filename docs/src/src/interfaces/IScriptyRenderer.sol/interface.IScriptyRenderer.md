# IScriptyRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/interfaces/IScriptyRenderer.sol)

**Inherits:**
[IRenderer](/src/interfaces/IRenderer.sol/interface.IRenderer.md)

**Author:**
fx(hash)

Renderer for building onchain metadata of FxGenArt721 tokens using Scripty.sol


## Functions
### contractURI

Gets the contact-level metadata for a project


```solidity
function contractURI(string memory _defaultURI) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_defaultURI`|`string`|Fallback URI|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI of the contract metadata|


### ethfsFileStorage

Returns the address of ETHFSFileStorage contract


```solidity
function ethfsFileStorage() external view returns (address);
```

### getEncodedHTML

Builds the encoded HTML request for header and body tags


```solidity
function getEncodedHTML(uint256 _tokenId, bytes32 _seed, bytes memory _fxParams, HTMLRequest memory _htmlRequest)
    external
    view
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the randomly generated fxHash seed|
|`_fxParams`|`bytes`|Bytes value of user-input params|
|`_htmlRequest`|`HTMLRequest`|HTMLRequest of script|


### getImageURI

Generates the image URI for a token ID


```solidity
function getImageURI(string memory _defaultURI, string memory _baseURI, uint256 _tokenId)
    external
    view
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_defaultURI`|`string`|Fallback URI|
|`_baseURI`|`string`|URI of the content identifier|
|`_tokenId`|`uint256`|ID of the token|


### renderOnchain

Renders the token scripts onchain


```solidity
function renderOnchain(
    uint256 _tokenId,
    bytes32 _seed,
    bytes calldata _fxParams,
    HTMLRequest calldata _animationURL,
    HTMLRequest calldata _attributes
) external view returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the randomly generated fxHash seed|
|`_fxParams`|`bytes`|Bytes value of user-input params|
|`_animationURL`|`HTMLRequest`|HTMLRequest of token animation|
|`_attributes`|`HTMLRequest`|HTMLRequest of token attributes|


### scriptyBuilder

Returns the address of ScriptyBuilder contract


```solidity
function scriptyBuilder() external view returns (address);
```

### scriptyStorage

Returns the address of ScriptyStorage contract


```solidity
function scriptyStorage() external view returns (address);
```

### tokenURI

Gets the metadata for a token


```solidity
function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_data`|`bytes`|Additional data used to construct metadata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI of the token metadata|


