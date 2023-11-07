# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

Struct of generative art information
- `seed` Hash of seed generated for randomly minted tokens
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    bytes32 seed;
    bytes fxParams;
}
```

