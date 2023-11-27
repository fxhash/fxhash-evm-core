# IRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/interfaces/IRenderer.sol)

**Author:**
fx(hash)

Interface for FxGenArt721 tokens to interact with renderers


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


