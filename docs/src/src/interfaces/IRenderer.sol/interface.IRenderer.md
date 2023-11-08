# IRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/interfaces/IRenderer.sol)

**Author:**
fx(hash)

Interface for FxGenArt721 tokens to interact with renderers


## Functions
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


