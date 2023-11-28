# IRoyaltyManager
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/interfaces/IRoyaltyManager.sol)

**Author:**
fx(hash)

Extension for managing secondary royalties of FxGenArt721 tokens


## Functions
### getRoyalties

Gets the royalties for a specific token ID


```solidity
function getRoyalties(uint256 _tokenId) external view returns (address[] memory, uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|Total receivers and basis points|
|`<none>`|`uint256[]`||


### royaltyInfo

Returns the royalty information for a specific token ID and sale price


```solidity
function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_salePrice`|`uint256`|Sale price of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|receiver Address receiving royalties|
|`<none>`|`uint256`|royaltyAmount Amount to royalties being paid out|


## Events
### TokenIdRoyaltiesUpdated
Event emitted when the royalties for a token ID have been updated


```solidity
event TokenIdRoyaltiesUpdated(uint256 indexed _tokenId, address _receiver, uint96 _basisPoints);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_receiver`|`address`|Addresses receiving the royalties|
|`_basisPoints`|`uint96`|Points used to calculate royalty payments (100 = 1%)|

### TokenRoyaltiesUpdated
Event emitted when the royalties for a list of receivers have been updated


```solidity
event TokenRoyaltiesUpdated(
    address indexed _receiver, address[] _receivers, uint32[] _allocations, uint96 _basisPoints
);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receiver`|`address`|The address receiving royalties for the token either an account or a split address|
|`_receivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocations used to determine the proportional share of royalty payments|
|`_basisPoints`|`uint96`|Points used to calculate royalty payments (100 = 1%)|

## Errors
### BaseRoyaltiesNotSet
Error thrown when the royalties are not set


```solidity
error BaseRoyaltiesNotSet();
```

### InvalidRoyaltyConfig
Error thrown when royalty configuration is greater than or equal to 100%


```solidity
error InvalidRoyaltyConfig();
```

### LengthMismatch
Error thrown when array lengths do not match


```solidity
error LengthMismatch();
```

### MoreThanOneRoyaltyReceiver
Error thrown when more than one royalty receiver is set


```solidity
error MoreThanOneRoyaltyReceiver();
```

### NonExistentToken
Error thrown when the token ID does not exist


```solidity
error NonExistentToken();
```

### NoRoyaltyReceiver
Error thrown when royalty receiver is zero address


```solidity
error NoRoyaltyReceiver();
```

### OverMaxBasisPointsAllowed
Error thrown when total basis points exceeds maximum value allowed


```solidity
error OverMaxBasisPointsAllowed();
```

### TokenRoyaltiesNotSet
Error thrown when the token royalties are not set


```solidity
error TokenRoyaltiesNotSet();
```

