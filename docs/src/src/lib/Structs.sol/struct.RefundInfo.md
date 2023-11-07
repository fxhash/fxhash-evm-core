# RefundInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of refund information
- `lastPrice` Price of last sale before selling out
- `minterInfo` Mapping of minter address to struct of minter information


```solidity
struct RefundInfo {
    uint256 lastPrice;
    mapping(address minter => MinterInfo) minterInfo;
}
```

