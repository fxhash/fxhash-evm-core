# RoyaltyManager
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/tokens/extensions/RoyaltyManager.sol)

**Inherits:**
[IRoyaltyManager](/src/interfaces/IRoyaltyManager.sol/interface.IRoyaltyManager.md)

**Author:**
fx(hash)

See the documentation in {IRoyaltyManager}


## State Variables
### baseRoyalties
Returns royalty information of index in array list


```solidity
RoyaltyInfo public baseRoyalties;
```


### tokenRoyalties
Mapping of token ID to array of royalty information


```solidity
mapping(uint256 => RoyaltyInfo) public tokenRoyalties;
```


## Functions
### getRoyalties

Gets the royalties for a specific token ID


```solidity
function getRoyalties(uint256 _tokenId)
    external
    view
    returns (address[] memory receivers, uint256[] memory basisPoints);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address[]`|Total receivers and basis points|
|`basisPoints`|`uint256[]`||


### royaltyInfo

Returns the royalty information for a specific token ID and sale price


```solidity
function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 amount);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_salePrice`|`uint256`|Sale price of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`receiver`|`address`|Address receiving royalties|
|`amount`|`uint256`|royaltyAmount Amount to royalties being paid out|


### _setBaseRoyalties

Sets the base royalties for all tokens


```solidity
function _setBaseRoyalties(address[] calldata _receivers, uint32[] calldata _allocations, uint96 _basisPoints)
    internal
    virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address[]`|Array of addresses receiving royalties|
|`_allocations`|`uint32[]`|Array of allocation amounts for calculating royalty shares|
|`_basisPoints`|`uint96`|Total allocation scalar for calculating royalty shares|


### _setTokenRoyalties

compute split if necessary

Sets the royalties for a specific token ID


```solidity
function _setTokenRoyalties(uint256 _tokenId, address _receiver, uint96 _basisPoints) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_receiver`|`address`|Address receiving royalty payments|
|`_basisPoints`|`uint96`|Total allocation scalar for calculating royalty shares|


### _exists

*Checks if the token ID exists*


```solidity
function _exists(uint256 _tokenId) internal view virtual returns (bool);
```

### _checkRoyalties

*Checks if:
1. Total basis points of royalties exceeds 10,000 (100%)
2. A single receiver exceeds 2,500 (25%)*


```solidity
function _checkRoyalties(address[] memory _receivers, uint32[] memory _allocations, uint96 _basisPoints)
    internal
    pure;
```

