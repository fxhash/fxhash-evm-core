# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of metadata information
- `baseURI` Decoded URI of content identifier
- `onchainPointer` Address of bytes-encoded data rendered onchain


```solidity
struct MetadataInfo {
    bytes baseURI;
    address onchainPointer;
}
```

