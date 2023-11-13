# IPFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/renderers/IPFSRenderer.sol)

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


