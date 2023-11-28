# RoyaltyInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

Struct of royalty information
- `receiver` Address receiving royalties
- `basisPoints` Points used to calculate the royalty payment (0.01%)


```solidity
struct RoyaltyInfo {
    address receiver;
    uint96 basisPoints;
}
```

