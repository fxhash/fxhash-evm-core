# ReserveInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of reserve information
- `startTime` Start timestamp of minter
- `endTime` End timestamp of minter
- `allocation` Allocation amount for minter


```solidity
struct ReserveInfo {
    uint64 startTime;
    uint64 endTime;
    uint128 allocation;
}
```

