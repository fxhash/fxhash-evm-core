# MinterInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

Struct of minter information
- `totalMints` Total number of mints executed by the minter
- `totalPaid` Total amount paid by the minter


```solidity
struct MinterInfo {
    uint128 totalMints;
    uint128 totalPaid;
}
```

