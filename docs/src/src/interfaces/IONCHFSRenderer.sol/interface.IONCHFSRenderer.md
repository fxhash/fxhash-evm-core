# IONCHFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/interfaces/IONCHFSRenderer.sol)

**Inherits:**
[IRenderer](/src/interfaces/IRenderer.sol/interface.IRenderer.md)

**Author:**
fx(hash)

Renderer for reconstructing metadata of FxGenArt721 tokens stored onchain through ONCHFS


## Functions
### contractRegistry

Returns address of the FxContractRegistry contract


```solidity
function contractRegistry() external view returns (address);
```

### contractURI

Gets the contact-level metadata for the project


```solidity
function contractURI() external view returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URI of the contract metadata|


### getAnimationURL

Generates the animation URL for a token ID


```solidity
function getAnimationURL(bytes32 _onchfsCID, uint256 _tokenId, address _minter, bytes32 _seed, bytes memory _fxParams)
    external
    pure
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_onchfsCID`|`bytes32`|CID hash of token animation|
|`_tokenId`|`uint256`|ID of the token|
|`_minter`|`address`|Address of initial token owner|
|`_seed`|`bytes32`|Hash of randomly generated seed|
|`_fxParams`|`bytes`|Random sequence of fixed-length bytes used as token input|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URL of the animation pointer|


### getAttributes

Generates the list of attributes for a token ID


```solidity
function getAttributes(address _contractAddr, string memory _baseURI, uint256 _tokenId)
    external
    view
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddr`|`address`|Address of the token contract|
|`_baseURI`|`string`|URI of the content identifier|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|List of token attributes|


### getExternalURL

Generates the external URL for a token ID


```solidity
function getExternalURL(address _contractAddr, uint256 _tokenId) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddr`|`address`|Address of the token contract|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URL of the external token pointer|


### getImageURL

Generates the image URL for a token ID


```solidity
function getImageURL(address _contractAddr, string memory _baseURI, uint256 _tokenId)
    external
    view
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contractAddr`|`address`|Address of the token contract|
|`_baseURI`|`string`|URI of the content identifier|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|URL of the image pointer|


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


