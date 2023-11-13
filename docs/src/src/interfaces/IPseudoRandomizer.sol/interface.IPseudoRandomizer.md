# IPseudoRandomizer
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/interfaces/IPseudoRandomizer.sol)

**Inherits:**
[IRandomizer](/src/interfaces/IRandomizer.sol/interface.IRandomizer.md)

**Author:**
fx(hash)

Randomizer for generating psuedorandom seeds for newly minted tokens


## Functions
### generateSeed

Generates random seed for token using entropy


```solidity
function generateSeed(uint256 _tokenId) external view returns (bytes32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|Hash of the seed|


### requestRandomness

Requests random seed for a given token


```solidity
function requestRandomness(uint256 _tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|ID of the token|


