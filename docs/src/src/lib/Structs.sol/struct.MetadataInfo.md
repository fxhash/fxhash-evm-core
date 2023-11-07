# MetadataInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/22e6538fd4576a4eee62705cd3e376e2623a19b3/src/lib/Structs.sol)

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

