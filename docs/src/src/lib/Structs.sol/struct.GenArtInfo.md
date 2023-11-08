# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

Struct of generative art information
- `seed` Hash of seed generated for randomly minted tokens
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}
```

