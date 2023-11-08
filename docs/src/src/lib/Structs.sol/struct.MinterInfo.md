# MinterInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

Struct of minter information
- `totalMints` Total number of mints executed by the minter
- `totalPaid` Total amount paid by the minter


```solidity
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}
```

