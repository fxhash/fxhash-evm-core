# IScriptyRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/interfaces/IScriptyRenderer.sol)

**Inherits:**
[IRenderer](/src/interfaces/IRenderer.sol/interface.IRenderer.md)

**Author:**
fx(hash)

Renderer for building onchain metadata of FxGenArt721 tokens using Scripty.sol


## Functions
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
|`_data`|`bytes`|Additional data used to construct onchain metadata|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI of the token metadata|


