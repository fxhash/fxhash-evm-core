# RoyaltyInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

Struct of royalty information
- `receiver` Address receiving royalties
- `basisPoints` Points used to calculate the royalty payment (0.01%)


```solidity
struct RoyaltyInfo {
    address payable receiver;
    uint96 basisPoints;
}
```

