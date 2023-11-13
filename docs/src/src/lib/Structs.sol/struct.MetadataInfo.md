# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

Struct of metadata information
- `baseURI` Decoded URI of content identifier
- `onchainData` Bytes-encoded data rendered onchain


```solidity
struct MetadataInfo {
    bytes baseURI;
    bytes onchainData;
}
```

