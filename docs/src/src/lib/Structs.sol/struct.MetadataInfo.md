# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/1ca8488246dda0c8af0201fe562392f87b349fa1/src/lib/Structs.sol)

Struct of metadata information
- `baseURI` Decoded URI of content identifier
- `onchainPointer` Address of bytes-encoded data rendered onchain


```solidity
struct MetadataInfo {
    bytes baseURI;
    address onchainPointer;
}
```

