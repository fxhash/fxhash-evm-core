# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

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

