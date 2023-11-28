# PseudoRandomizer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/randomizers/PseudoRandomizer.sol)

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


