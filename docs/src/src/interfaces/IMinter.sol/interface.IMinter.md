# IMinter
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/interfaces/IMinter.sol)

**Author:**
fx(hash)

Interface for FxGenArt721 tokens to interact with minters


## Functions
### setMintDetails

Sets the mint details for token reserves


```solidity
function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_reserveInfo`|`ReserveInfo`|Reserve information for the token|
|`_mintDetails`|`bytes`|Details of the mint pertaining to the minter|


