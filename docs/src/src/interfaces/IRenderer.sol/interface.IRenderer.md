# IRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IRenderer.sol)

**Author:**
fx(hash)

Interface for FxGenArt721 tokens to interact with renderers


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


