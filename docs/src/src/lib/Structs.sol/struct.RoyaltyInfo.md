# RoyaltyInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of royalty information
- `receiver` Address receiving royalties
- `basisPoints` Points used to calculate the royalty payment (0.01%)


```solidity
struct RoyaltyInfo {
    address receiver;
    uint96 basisPoints;
}
```

