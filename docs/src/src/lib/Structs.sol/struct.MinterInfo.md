# MinterInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of minter information
- `totalMints` Total number of mints executed by the minter
- `totalPaid` Total amount paid by the minter


```solidity
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}
```

