# IToken
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/interfaces/IToken.sol)

**Author:**
fx(hash)

Interface for minters to interact with tokens


## Functions
### mint

Mints arbitrary number of tokens

*Only callable by registered minter contracts*


```solidity
function mint(address _to, uint256 _amount, uint256 _payment) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|Address receiving tokens|
|`_amount`|`uint256`|Number of tokens being minted|
|`_payment`|`uint256`|Total payment amount of the transaction|

