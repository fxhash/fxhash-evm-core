# RoyaltyInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of royalty information
- `receiver` Address receiving royalties
- `basisPoints` Points used to calculate the royalty payment (0.01%)


```solidity
struct RoyaltyInfo {
    address payable receiver;
    uint96 basisPoints;
}
```

