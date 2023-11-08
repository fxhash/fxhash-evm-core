# PseudoRandomizer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/randomizers/PseudoRandomizer.sol)

**Inherits:**
[IPseudoRandomizer](/src/interfaces/IPseudoRandomizer.sol/interface.IPseudoRandomizer.md)

**Author:**
fx(hash)

*See the documentation in {IPseudoRandomizer}*


## Functions
### requestRandomness


```solidity
function requestRandomness(uint256 _tokenId) external;
```

### generateSeed

Generates random seed for token using entropy


```solidity
function generateSeed(uint256 _tokenId) public view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Hash of the seed|


