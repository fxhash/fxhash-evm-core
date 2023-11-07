# RoyaltyManager
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/tokens/extensions/RoyaltyManager.sol)

**Inherits:**
[IRoyaltyManager](/src/interfaces/IRoyaltyManager.sol/interface.IRoyaltyManager.md)

**Author:**
fx(hash)

See the documentation in {IRoyaltyManager}


## State Variables
### baseRoyalties
Returns royalty information of index in array


```solidity
RoyaltyInfo[] public baseRoyalties;
```


### tokenRoyalties
Mapping of token ID to array of royalty information


```solidity
mapping(uint256 => RoyaltyInfo[]) public tokenRoyalties;
```


## Functions
### getRoyalties

Gets the royalties for a specific token ID


```solidity
function getRoyalties(uint256 _tokenId)
    external
    view
    returns (address payable[] memory receivers, uint256[] memory basisPoints);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`receivers`|`address payable[]`|Total receivers and basis points|
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


### setBaseRoyalties

Sets the base royalties for all tokens


```solidity
function setBaseRoyalties(address payable[] calldata _receivers, uint96[] calldata _basisPoints) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receivers`|`address payable[]`|Array of addresses receiving royalties|
|`_basisPoints`|`uint96[]`|Array of points used to calculate royalty payments (0.01% per receiver)|


### setTokenRoyalties

Sets the royalties for a specific token ID


```solidity
function setTokenRoyalties(uint256 _tokenId, address payable[] calldata _receivers, uint96[] calldata _basisPoints)
    public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|
|`_receivers`|`address payable[]`|Array of addresses receiving royalties|
|`_basisPoints`|`uint96[]`|Array of points used to calculate royalty payments (0.01% per receiver)|


### _exists

*Checks if the token ID exists*


```solidity
function _exists(uint256 _tokenId) internal view virtual returns (bool);
```

### _checkRoyalties

*Checks if the total basis points of royalties exceeds 10,000 (100%)*


```solidity
function _checkRoyalties(uint96[] memory _basisPoints, uint256 _length) internal pure;
```

