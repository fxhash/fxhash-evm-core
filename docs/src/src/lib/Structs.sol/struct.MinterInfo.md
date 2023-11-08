# MinterInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of minter information
- `totalMints` Total number of mints executed by the minter
- `totalPaid` Total amount paid by the minter


```solidity
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}
```

