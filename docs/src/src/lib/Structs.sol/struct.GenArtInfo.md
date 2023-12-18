# GenArtInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of generative art information
- `minter` Address of initial token owner
- `seed` Hash of randomly generated seed
- `fxParams` Random sequence of fixed-length bytes used as token input


```solidity
struct GenArtInfo {
    address minter;
    bytes32 seed;
    bytes fxParams;
}
```

