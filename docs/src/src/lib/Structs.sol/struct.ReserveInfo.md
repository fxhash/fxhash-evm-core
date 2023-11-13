# ReserveInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

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

