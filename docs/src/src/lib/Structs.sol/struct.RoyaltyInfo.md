# RoyaltyInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/3196ec292bff15f41085b94e4b488f73ce88013c/src/lib/Structs.sol)

Struct of royalty information
- `receiver` Address receiving royalties
- `basisPoints` Points used to calculate the royalty payment (0.01%)


```solidity
struct RoyaltyInfo {
    address payable receiver;
    uint96 basisPoints;
}
```

