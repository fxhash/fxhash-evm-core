# IIPFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/interfaces/IIPFSRenderer.sol)

**Inherits:**
[IRenderer](/src/interfaces/IRenderer.sol/interface.IRenderer.md)

**Author:**
fx(hash)

Renderer for constructing offchain metadata of FxGenArt721 tokens pinned to IPFS


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


### getMetadataURL

Generates the metadata URL for a token ID


```solidity
function getMetadataURL(address _contractAddr, string memory _baseURI, uint256 _tokenId)
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
|`<none>`|`string`|URL of the JSON metadata|


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


