# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

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

