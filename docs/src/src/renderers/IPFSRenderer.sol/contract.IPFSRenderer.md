# IPFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/renderers/IPFSRenderer.sol)

**Inherits:**
[IIPFSRenderer](/src/interfaces/IIPFSRenderer.sol/interface.IIPFSRenderer.md)

**Author:**
fx(hash)

*See the documentation in {IIPFSRenderer}*


## State Variables
### contractRegistry

```solidity
address public immutable contractRegistry;
```


## Functions
### constructor

*Initializes FxContractRegistry*


```solidity
constructor(address _contractRegistry);
```

### contractURI


```solidity
function contractURI() external view returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
```

### getMetadataURL

Generates the metadata URL for a token ID


```solidity
function getMetadataURL(address _contractAddr, string memory _baseURI, uint256 _tokenId)
    public
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


