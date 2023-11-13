# IPFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/renderers/IPFSRenderer.sol)

**Inherits:**
[IIPFSRenderer](/src/interfaces/IIPFSRenderer.sol/interface.IIPFSRenderer.md)

**Author:**
fx(hash)

*See the documentation in {IIPFSRenderer}*


## Functions
### contractURI


```solidity
function contractURI(string memory _defaultURI) external view returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
```

### getMetadataURI

Generates the metadata URI for a token ID


```solidity
function getMetadataURI(string memory _defaultURI, string memory _baseURI, uint256 _tokenId)
    public
    view
    returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_defaultURI`|`string`|Fallback URI|
|`_baseURI`|`string`|URI of the content identifier|
|`_tokenId`|`uint256`|ID of the token|


