# IRoyaltyManager
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/interfaces/IRoyaltyManager.sol)

**Author:**
fx(hash)

Extension for managing secondary royalties of FxGenArt721 tokens


## Functions
### getRoyalties

Gets the royalties for a specific token ID


```solidity
function getRoyalties(uint256 _tokenId) external view returns (address payable[] memory, uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address payable[]`|Total receivers and basis points|
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
event TokenIdRoyaltiesUpdated(uint256 indexed tokenId, address payable[] receivers, uint96[] basisPoint);
```

### TokenRoyaltiesUpdated
Event emitted when the royalties for a list of receivers have been updated


```solidity
event TokenRoyaltiesUpdated(address payable[] receivers, uint96[] basisPoints);
```

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

