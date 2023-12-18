# ONCHFSRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/renderers/ONCHFSRenderer.sol)

**Inherits:**
[IONCHFSRenderer](/src/interfaces/IONCHFSRenderer.sol/interface.IONCHFSRenderer.md)

**Author:**
fx(hash)

*See the documentation in {IONCHFSRenderer}*


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

### getAttributes

Generates the list of attributes for a token ID


```solidity
function getAttributes(address _contractAddr, string memory _baseURI, uint256 _tokenId)
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
|`<none>`|`string`|List of token attributes|


### getExternalURL

Generates the external URL for a token ID


```solidity
function getExternalURL(address _contractAddr, uint256 _tokenId) public view returns (string memory);
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
|`<none>`|`string`|URL of the image pointer|


### getAnimationURL

Generates the animation URL for a token ID


```solidity
function getAnimationURL(bytes32 _onchfsCID, uint256 _tokenId, address _minter, bytes32 _seed, bytes memory _fxParams)
    public
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


### _renderJSON

*Reconstructs JSON metadata of token onchain*


```solidity
function _renderJSON(
    address _contractAddr,
    uint256 _tokenId,
    string memory _description,
    string memory _baseURI,
    string memory _animationURL
) internal view returns (string memory);
```

