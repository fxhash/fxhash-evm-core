# RefundInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

Struct of refund information
- `lastPrice` Price of last sale before selling out
- `minterInfo` Mapping of minter address to struct of minter information


```solidity
struct RefundInfo {
    uint256 lastPrice;
    mapping(address minter => MinterInfo) minterInfo;
}
```

