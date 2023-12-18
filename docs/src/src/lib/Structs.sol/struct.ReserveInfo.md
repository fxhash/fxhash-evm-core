# ReserveInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

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

