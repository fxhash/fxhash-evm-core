# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

Struct of generative art information
- `seed` Hash of seed generated for randomly minted tokens
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}
```

