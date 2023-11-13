# IIPFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IIPFSRenderer.sol)

**Inherits:**
[IRenderer](/src/interfaces/IRenderer.sol/interface.IRenderer.md)

**Author:**
fx(hash)

Renderer for constructing offchain metadata of FxGenArt721 tokens pinned to IPFS


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


### getMetadataURI

Generates the metadata URI for a token ID


```solidity
function getMetadataURI(string memory _defaultURI, string memory _baseURI, uint256 _tokenId)
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


