# MinterInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

Struct of minter information
- `totalMints` Total number of mints executed by the minter
- `totalPaid` Total amount paid by the minter


```solidity
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}
```

