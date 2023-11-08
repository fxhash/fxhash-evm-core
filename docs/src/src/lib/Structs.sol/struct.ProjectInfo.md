# ProjectInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/ace7e57339c07ca2ed3c7a6bef724ed3baae64f8/src/lib/Structs.sol)

Struct of project information
- `onchain` Flag inidicated if project metadata is rendered onchain
- `mintEnabled` Flag inidicating if minting is enabled
- `burnEnabled` Flag inidicating if burning is enabled
- `inputSize` Maximum input size of fxParams bytes data
- `maxSupply` Maximum supply of tokens
- `contractURI` CID hash of collection metadata


```solidity
struct ProjectInfo {
    bool onchain;
    bool mintEnabled;
    bool burnEnabled;
    uint120 maxSupply;
    uint120 inputSize;
    string contractURI;
}
```

