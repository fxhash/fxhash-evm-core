# ReserveInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/lib/Structs.sol)

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

