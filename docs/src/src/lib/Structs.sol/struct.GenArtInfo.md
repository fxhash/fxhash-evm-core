# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of generative art information
- `seed` Hash of seed generated for randomly minted tokens
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}
```

