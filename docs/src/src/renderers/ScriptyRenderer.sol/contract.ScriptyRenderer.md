# ScriptyRenderer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/renderers/ScriptyRenderer.sol)

**Inherits:**
[IScriptyRenderer](/src/interfaces/IScriptyRenderer.sol/interface.IScriptyRenderer.md)

**Author:**
fx(hash)

*See the documentation in {IScriptyRenderer}*


## State Variables
### ethfsFileStorage
Returns the address of ETHFSFileStorage contract


```solidity
address public immutable ethfsFileStorage;
```


### scriptyBuilder
Returns the address of ScriptyBuilder contract


```solidity
address public immutable scriptyBuilder;
```


### scriptyStorage
Returns the address of ScriptyStorage contract


```solidity
address public immutable scriptyStorage;
```


## Functions
### constructor

*Initializes ETHFSFileStorage, ScriptyStorage and ScriptyBuilder*


```solidity
constructor(address _ethfsFileStorage, address _scriptyStorage, address _scriptyBuilder);
```

### contractURI


```solidity
function contractURI(string memory _defaultMetadataURI) external view returns (string memory);
```

### tokenURI


```solidity
function tokenURI(uint256 _tokenId, bytes calldata _data) external view returns (string memory);
```

### getEncodedHTML

Builds the encoded HTML request for header and body tags


```solidity
function getEncodedHTML(uint256 _tokenId, bytes32 _seed, bytes memory _fxParams, HTMLRequest memory _htmlRequest)
    public
    view
    returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the randomly generated fxHash seed|
|`_fxParams`|`bytes`|Bytes value of user-input params|
|`_htmlRequest`|`HTMLRequest`|HTMLRequest of script|


### getImageURI

*IScriptyRenderer*


```solidity
function getImageURI(string memory _defaultURI, string memory _baseURI, uint256 _tokenId)
    public
    view
    returns (string memory);
```

### renderOnchain

Renders the token scripts onchain


```solidity
function renderOnchain(
    uint256 _tokenId,
    bytes32 _seed,
    bytes memory _fxParams,
    HTMLRequest memory _animation,
    HTMLRequest memory _attributes
) public view returns (bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_seed`|`bytes32`|Hash of the randomly generated fxHash seed|
|`_fxParams`|`bytes`|Bytes value of user-input params|
|`_animation`|`HTMLRequest`||
|`_attributes`|`HTMLRequest`|HTMLRequest of token attributes|


### _getParamsContent

*Gets the params content for tokens minted with fxParams*


```solidity
function _getParamsContent(uint256 _tokenId, bytes memory _fxParams) internal pure returns (bytes memory);
```

### _getSeedContent

*Gets the seed content for randomly minted tokens*


```solidity
function _getSeedContent(uint256 _tokenId, bytes32 _seed) internal pure returns (bytes memory);
```

