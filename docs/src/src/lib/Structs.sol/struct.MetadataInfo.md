# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/7502dc47d919e0bb1248e7f953c914adde69d025/src/lib/Structs.sol)

Struct of metadata information
- `baseURI` CID hash of token metadata
- `imageURI` CID hash of token images
- `onchainData` Bytes-encoded data rendered onchain


```solidity
struct MetadataInfo {
    string baseURI;
    string imageURI;
    bytes onchainData;
}
```

