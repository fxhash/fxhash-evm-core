# ReserveInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

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

