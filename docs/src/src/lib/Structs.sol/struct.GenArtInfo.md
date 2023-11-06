# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of generative art information
- `seed` Hash of seed generated for randomly minted tokens
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}
```

